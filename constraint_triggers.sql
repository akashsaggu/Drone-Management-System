--==============================================================================================================
-- CONSTRAINT TRIGGERS
--==============================================================================================================
-- The following constraint triggers have been implemented onto group_02.flightpath table
--==============================================================================================================
-- Trigger 1: 15 metre minimum elevation above ground level
CREATE OR REPLACE FUNCTION group_02.flightpath_15m_elevation()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
	min_path_elev numeric;
BEGIN
	min_path_elev := ST_ZMin(NEW.geom);
    IF min_path_elev < 15 
    THEN
        RAISE EXCEPTION 'Minimum elevation of flight path above ground level is %m, which is below CASA 15m constraint', min_path_elev;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema
CREATE TRIGGER FlightPath_15m_Elevation_Trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.FlightPath_15m_Elevation();

----------------------------------------------------------------------------------------------------------------
-- Trigger 2: 120 metre maximum elevation above ground level
CREATE OR REPLACE FUNCTION group_02.flightpath_120m_elevation()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
	max_path_elev numeric;
BEGIN
	max_path_elev := ST_ZMax(NEW.geom);
    IF max_path_elev > 120 
    THEN
        RAISE EXCEPTION 'Maximum elevation of flight path above ground level is %m, which is more than CASA 120m constraint', max_path_elev;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema
CREATE TRIGGER FlightPath_120m_Elevation_Trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.FlightPath_120m_Elevation();

----------------------------------------------------------------------------------------------------------------
-- Trigger 3: Can't fly over a beach trigger
CREATE OR REPLACE FUNCTION group_02.flightpath_beach_constraint()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
	IF EXISTS(
		SELECT 1
		FROM (SELECT ST_Transform((ST_Dump(geom)).geom, 7855) as geom
    			FROM group_02.victoriabeach) AS beach_poly
				WHERE ST_Intersects(ST_Transform(NEW.geom, 7855), beach_poly.geom))
    THEN
    	RAISE EXCEPTION 'Flight path intersects with a beach, which is one of CASA populous area';
	ELSE 
		RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPath
CREATE TRIGGER flightpath_beach_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.flightpath_beach_constraint();

----------------------------------------------------------------------------------------------------------------
-- Trigger 4: Can't fly within 30m of a helipad trigger
CREATE OR REPLACE FUNCTION group_02.flightpath_helipad_constraint()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
     -- Create a 30m around the helipad point and check if the flight path intersects with it
    IF EXISTS (
        SELECT 1
        FROM group_02.victoriahelipad as helipad
        WHERE ST_Intersects(ST_Transform(NEW.geom, 7855), ST_Buffer(ST_Transform(helipad.geom, 7855), 30))
    ) THEN
        RAISE EXCEPTION 'Flight Path intersects with the 30m buffer around a helipad';
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPath
CREATE TRIGGER flightpath_helipad_constraint_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.flightpath_helipad_constraint();

----------------------------------------------------------------------------------------------------------------
-- Trigger 5: Flightpath must stay within line of sight trigger
CREATE OR REPLACE FUNCTION group_02.flightpath_line_of_sight()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    max_los numeric;
BEGIN
	max_los := 5000;
	
     -- Check if point is within maximum line of sight
    IF NOT ST_Within(ST_Transform(NEW.geom, 7855), ST_Buffer(ST_Transform(ST_StartPoint(NEW.geom), 7855), max_los))
    THEN
        RAISE EXCEPTION 'Flight path is not within maximum line of sight';
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPath
CREATE TRIGGER flightpath_line_of_sight_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.flightpath_line_of_sight();

----------------------------------------------------------------------------------------------------------------
-- Trigger 6: Flightpath can't fly over a park trigger
CREATE OR REPLACE FUNCTION group_02.flightpath_park_constraint()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
	IF EXISTS(
		SELECT 1
		FROM (SELECT ST_Transform((ST_Dump(geom)).geom, 7855) as geom
    			FROM group_02.victoriapark) AS park_poly
				WHERE ST_Intersects(ST_Transform(NEW.geom, 7855), park_poly.geom))
    THEN
    	RAISE EXCEPTION 'Flight path intersects with a park, which is one of CASA populous area';
	ELSE 
		RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPath
CREATE TRIGGER flightpath_park_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPath
FOR EACH ROW
EXECUTE FUNCTION group_02.flightpath_park_constraint();

--==============================================================================================================
-- The following constraint triggers have been implemented onto group_02.flightplan table
--==============================================================================================================
-- Trigger 8: A drone with combined weight above 250g can't fly within 5.5km of an airport
CREATE OR REPLACE FUNCTION group_02.flightplan_airport_weight_constraint()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    total_weight numeric;
	flight_path geometry;
BEGIN
    -- Calculate total weight
    SELECT d.droneweight + b.BatteryWeight + s.SensorWeight INTO total_weight
    FROM group_02.Drone d
    JOIN group_02.Battery b ON d.BatteryID = b.BatteryID
    JOIN group_02.Sensor s ON d.SensorID = s.SensorID
    WHERE d.DroneID = NEW.DroneID;

	-- Get the FlightPath
    SELECT fpath.geom INTO flight_path
    FROM group_02.FlightPath fpath
    WHERE fpath.PathID = NEW.PathID;
	
     -- Create a 5.5km buffer around the airport geometries and check if the FlightPath intersects with it
    IF total_weight > 250 AND EXISTS (
        SELECT 1
        FROM group_02.victoriaairport as airport_buffer
        WHERE ST_Intersects(ST_Transform(flight_path, 7855), ST_Buffer(ST_Transform(airport_buffer.geom, 7855), 5500))
    ) THEN
        RAISE EXCEPTION 'Drone total weight is % grams, which exceeds maximum 250 grams and flight path intersects with the 5.5km buffer around an airport', total_weight;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightpath_airport_vicinity_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_airport_weight_constraint();

----------------------------------------------------------------------------------------------------------------
-- Trigger 9: A battery used in a flightplan must have been inspected within the last 2 years
CREATE OR REPLACE FUNCTION group_02.flightplan_battery_inspection()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if the battery inspection date is more than 2 years ago
    IF b.lastInspectionDate < CURRENT_DATE - INTERVAL '2 years'
    FROM group_02.Drone d
    JOIN group_02.Battery b ON d.BatteryID = b.BatteryID
    WHERE d.DroneID = NEW.DroneID THEN
        RAISE EXCEPTION 'Battery must have been inspected within the last 2 years for this FlightPlan';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_battery_inspection_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_battery_inspection();

----------------------------------------------------------------------------------------------------------------
-- Trigger 10: A battery must have enough charge time left to last the duration of a flight plan
CREATE OR REPLACE FUNCTION group_02.flightplan_battery_time_left()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    max_flight_time interval;
    remaining_battery_life interval;
BEGIN
    -- Calculate the expected flight time in kilometers
    SELECT (ST_Length(fp.geom::geography) / 1000 / (d.avgspeed)) * INTERVAL '1 hour' INTO max_flight_time
    FROM group_02.flightpath fp
    JOIN group_02.Drone d ON d.DroneID = NEW.DroneID
    WHERE fp.PathID = NEW.PathID;

    -- Calculate the remaining battery life
    SELECT (b.maxflighttime - d.BatteryUsed) INTO remaining_battery_life
    FROM group_02.Drone d
    JOIN group_02.Battery b ON d.BatteryID = b.BatteryID
    WHERE d.DroneID = NEW.DroneID;

    -- Check if the expected flight time in kilometers exceeds the remaining battery life
    IF max_flight_time > remaining_battery_life THEN
        RAISE EXCEPTION 'Flight path exceeds maximum battery flight time';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger
CREATE TRIGGER flightplan_battery_time_left_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_battery_time_left();

----------------------------------------------------------------------------------------------------------------
-- Trigger 11: A flightplan can only be flown during the day
CREATE OR REPLACE FUNCTION flightplan_day_constraint()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check between 5 AM and 7 PM
    IF NEW.flightstart::time < '05:00:00'::time OR NEW.flightend::time > '19:00:00'::time THEN
        RAISE EXCEPTION 'Flight start and end times must be between 5 AM and 7 PM.';
    END IF;

    RETURN NEW;
END;
$function$;

CREATE TRIGGER flightplan_day_constraint_trigger
BEFORE INSERT OR UPDATE
ON group_02.flightplan
FOR EACH ROW
EXECUTE FUNCTION flightplan_day_constraint();

----------------------------------------------------------------------------------------------------------------
-- Trigger 12: A flightplan can't fly above the maximum altitude of a sensor
CREATE OR REPLACE FUNCTION group_02.flightplan_max_sensor_altitude()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    max_altitude numeric;
    altitude_constraint numeric;
BEGIN
    -- Get sensor max altitude used in the drone
	SELECT s.MaxAltitude INTO altitude_constraint
	FROM group_02.Drone d
	JOIN group_02.Sensor s ON d.SensorID = s.SensorID
	WHERE d.DroneID = NEW.DroneID;

    -- Get max altitude
    SELECT ST_ZMax(fpath.geom) INTO max_altitude
    FROM group_02.FlightPath fpath
    WHERE fpath.PathID = NEW.PathID;

    -- Check if the maximum elevation of the FlightPath exceeds the drone's max altitude
    IF max_altitude > altitude_constraint 
	THEN
        RAISE EXCEPTION 'Flight Path max elevation is %m, which exceeded drone sensor max altitude of %m', max_altitude, altitude_constraint;
    ELSE
		RETURN NEW;
	END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_max_sensor_altitude_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_max_sensor_altitude();

----------------------------------------------------------------------------------------------------------------
-- Trigger 13: An operator can only fly one drone at a time
CREATE OR REPLACE FUNCTION flightplan_one_at_a_time()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
DECLARE
    overlapping_flightcount integer;
BEGIN
    -- Check if the operator is already flying another drone at the same time
    SELECT COUNT(*)
    INTO overlapping_flightcount
    FROM group_02.flightplan
    WHERE operatorid = NEW.operatorid
      AND (
          (NEW.flightstart >= flightstart AND NEW.flightstart <= flightend)
          OR (NEW.flightend >= flightstart AND NEW.flightend <= flightend)
      );

    IF overlapping_flightcount > 0 THEN
        RAISE EXCEPTION 'Operator is already flying another drone during this time period.';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create a trigger to enforce operator constraints
CREATE TRIGGER flightplan_one_at_a_time_trigger
BEFORE INSERT OR UPDATE
ON group_02.flightplan
FOR EACH ROW
EXECUTE FUNCTION flightplan_one_at_a_time();

----------------------------------------------------------------------------------------------------------------
-- Trigger 14: An operator who has flown 50 flight hours since their last refresher course can't fly
CREATE OR REPLACE FUNCTION group_02.flightplan_operator_training_hours()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    last_training_date DATE;
    flighthours INTERVAL;
BEGIN
    -- Get the last training date and course hours for the operator
    SELECT t.TrainingDate, o.flighthours INTO last_training_date, flighthours
    FROM group_02.Training t
    JOIN group_02.Operator o ON t.OperatorID = o.OperatorID
    WHERE t.OperatorID = NEW.OperatorID
    ORDER BY t.TrainingDate DESC
    LIMIT 1;

    -- Check if the last training date is not null and course hours exceed 50
    IF last_training_date IS NOT NULL AND flighthours > '50 hours' THEN
        RAISE EXCEPTION 'Operator may not undertake flights as flight hours since the last refresher course exceed 50';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_operator_training_hours_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_operator_training_hours();

----------------------------------------------------------------------------------------------------------------
-- Trigger 15: An operator who hasn't completed a refresher course within the last year can't fly
CREATE OR REPLACE FUNCTION group_02.FlightPlan_Operator_Training_Year()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    last_training_date DATE;
BEGIN
    -- Get the most recent training date for the operator
    SELECT MAX(TrainingDate) INTO last_training_date
    FROM group_02.Training tr
    WHERE tr.OperatorID = NEW.OperatorID;

    -- Check if the time since the last refresher course exceeds one year
    IF last_training_date IS NULL OR last_training_date < (CURRENT_DATE - INTERVAL '1 year') THEN
        RAISE EXCEPTION 'Operator must have a refresher course within the last year';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for Training
CREATE TRIGGER FlightPlan_Operator_Training_Year_Trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.FlightPlan_Operator_Training_Year();

----------------------------------------------------------------------------------------------------------------
-- Trigger 16: The combined weight of a battery, sensor and drone can't exceed the drone's payload
CREATE OR REPLACE FUNCTION flightplan_drone_weight_constraint()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    total_weight numeric;
    max_payload numeric;
BEGIN
    -- Calculate the total weight of the drone
    SELECT (d.droneweight + b.BatteryWeight + s.SensorWeight) INTO total_weight
    FROM group_02.Drone d
    JOIN group_02.Battery b ON d.BatteryID = b.BatteryID
    JOIN group_02.Sensor s ON d.SensorID = s.SensorID
    WHERE d.DroneID = NEW.DroneID;

    -- Retrieve the maximum payload capacity from the drone table
    SELECT payload INTO max_payload
    FROM group_02.Drone
    WHERE DroneID = NEW.DroneID;

    -- Check if the total weight exceeds the maximum payload
    IF total_weight > max_payload THEN
        RAISE EXCEPTION 'Total weight exceeds the maximum payload capacity for this drone';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_drone_weight_constraint_trigger
BEFORE INSERT OR UPDATE
ON group_02.flightplan
FOR EACH ROW
EXECUTE FUNCTION flightplan_drone_weight_constraint();

----------------------------------------------------------------------------------------------------------------
-- Trigger 17: A sensor can't be used in a flightplan if not calibrated within the last year
CREATE OR REPLACE FUNCTION group_02.flightplan_sensor_calibration()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if the sensor's last calibration date is not updated within the last year
    IF (SELECT s.LastCalibrationDate
        FROM group_02.Drone d
        JOIN group_02.Sensor s ON d.SensorID = s.SensorID
        WHERE d.DroneID = NEW.DroneID) < CURRENT_DATE - INTERVAL '1 year' THEN
        RAISE EXCEPTION 'Sensor must be calibrated within the last year for this FlightPlan';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_sensor_calibration_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_sensor_calibration();

----------------------------------------------------------------------------------------------------------------
-- Trigger 18: Only an operator with a commercial licemce may fly a flightplan for commercial purposes
CREATE OR REPLACE FUNCTION group_02.flightplan_valid_licence()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if the associated Operator has a valid licence
    IF NEW.commercialflight AND NOT EXISTS (
        SELECT 1
        FROM group_02.Operator o
        WHERE o.OperatorID = NEW.OperatorID AND o.Licence = true
    ) THEN
        RAISE EXCEPTION 'Commercial flight plans are only valid if the drone operator has a valid licence for commercial use';
    END IF;

    RETURN NEW;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_valid_licence_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_valid_licence();

----------------------------------------------------------------------------------------------------------------
-- Trigger 19: Only an employee may fly a flightplan outside of university grounds
CREATE OR REPLACE FUNCTION group_02.flightplan_within_unimelb_constraint()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    qualif varchar;
	flight_path geometry;
BEGIN
	
	-- Checks operator's qualification
	SELECT qualification INTO qualif
    FROM group_02.operator
    WHERE operatorid = NEW.operatorid;
	
	-- Get the FlightPath
    SELECT fpath.geom INTO flight_path
    FROM group_02.FlightPath fpath
    WHERE fpath.PathID = NEW.PathID;
	
	IF EXISTS(
		SELECT 1
		FROM (SELECT ST_Union(ST_Transform("ClusterLocation", 7855)) AS geom
    		FROM group_02.unimelbcampus) AS uni_poly
			WHERE (qualif != 'Employee') AND NOT (ST_WITHIN(ST_Transform(flight_path, 7855), uni_poly.geom))
		)
	THEN 
		RAISE EXCEPTION 'Operator has % qualification, who is not qualified to fly a drone path outside of university grounds', qualif;		 
	ELSE 
		RETURN NEW;
    END IF;
END;
$function$;

-- Create the trigger in the 'group_02' schema for FlightPlan
CREATE TRIGGER flightplan_within_unimelb_trigger
BEFORE INSERT OR UPDATE
ON group_02.FlightPlan
FOR EACH ROW
EXECUTE FUNCTION group_02.flightplan_within_unimelb_constraint();

