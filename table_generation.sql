--==============================================================================================================
-- TABLE GENERATION
--==============================================================================================================
-- The following code can be run to generate the tables
--==============================================================================================================
-- Airport
DROP TABLE IF EXISTS group_02.victoriaairport;
CREATE TABLE group_02.victoriaairport (
    id INTEGER,
    name CHARACTER VARYING,
    PRIMARY KEY (id)
);

-- Add Geometric Column
SELECT addGeometryColumn('group_02',
                        'victoriaairport',
                        'geom',
                        4326,
                        'MULTIPOLYGON',
                        2);

----------------------------------------------------------------------------------------------------------------
-- Battery
DROP TABLE IF EXISTS group_02.Battery;
CREATE TABLE group_02.Battery (
    BatteryID INTEGER,
    BatteryWeight NUMERIC,
    LastInspectionDate DATE,
    MaxFlightTime INTERVAL
    PRIMARY KEY (BatteryID)
);

----------------------------------------------------------------------------------------------------------------
-- Beach
DROP TABLE IF EXISTS group_02.victoriabeach;
CREATE TABLE group_02.victoriabeach (
    id INTEGER,
    name_label CHARACTER VARYING,
    featsubtyp CHARACTER VARYING,
    PRIMARY KEY (id)
);

-- Add Geometric Column
SELECT addGeometryColumn('group_02',
                        'victoriabeach',
                        'geom',
                        4326,
                        'MULTIPOLYGON',
                        2);

----------------------------------------------------------------------------------------------------------------
-- DEM
DROP TABLE IF EXISTS group_02.victoriadem;
CREATE TABLE group_02.victoriadem (
    RID INTEGER,
    Rast RASTER,
    PRIMARY KEY(RID)
);

----------------------------------------------------------------------------------------------------------------
-- Drone
DROP TABLE IF EXISTS group_02.Drone;
CREATE TABLE group_02.Drone (
    DroneID INTEGER,
    SensorID INTEGER,
    BatteryID INTEGER,
    MaxDroneWeight NUMERIC,
    BatteryUsed INTERVAL,
    AvgSpeed NUMERIC,
    Payload NUMERIC,
    PRIMARY KEY (DroneID)
);

----------------------------------------------------------------------------------------------------------------
-- Flightpath
DROP TABLE IF EXISTS group_02.FlightPath;
CREATE TABLE group_02.FlightPath (
    PathID NUMERIC,
    MaxElev NUMERIC,
    MinElev NUMERIC,
    DiffElev NUMERIC,
    PRIMARY KEY (PathID)
);
SELECT addGeometryColumn('group_02',
                        'flightpath',
                        'geom',
                        4326,
                        'LINESTRINGZ',
                        3);
SELECT addGeometryColumn('group_02',
                        'flightpath',
                        'startpoint',
                        4326,
                        'POINT',
                        2);

----------------------------------------------------------------------------------------------------------------
-- Flightplan
DROP TABLE IF EXISTS group_02.FlightPlan;
CREATE TABLE group_02.FlightPlan (
    FlightID INTEGER,
    FlightStart TIMESTAMP WITHOUT TIME ZONE,
    OperatorID INTEGER,
    PathID INTEGER,
    DroneID INTEGER,
    flightend TIMESTAMP WITHOUT TIME ZONE,
    commercialflight BOOLEAN,
    closeByHospital CHARACTER VARYING,
    PRIMARY KEY (FlightID)
);

----------------------------------------------------------------------------------------------------------------
-- Helipad
DROP TABLE IF EXISTS group_02.victoriahelipad;
CREATE TABLE group_02.victoriahelipad (
    id INTEGER,
    name CHARACTER VARYING,
    PRIMARY KEY (id)
);

-- Add Geometric Column
SELECT addGeometryColumn('group_02',
                        'victoriahelipad',
                        'geom',
                        4326,
                        'POINT',
                        2);

----------------------------------------------------------------------------------------------------------------
-- Hospital
DROP TABLE IF EXISTS group_02.victoriahospital;
CREATE TABLE group_02.victoriahospital (
    HospitalID INTEGER,
    HospitalName CHARACTER VARYING,
    Latitude float(10),
    Longitude float(10),
    PRIMARY KEY (HospitalID)
);
SELECT addGeometryColumn('group_02',
                        'victoriahospital',
                        'geom',
                        4326,
                        'POINT',
                        2);
UPDATE group_02.victoriahospital SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

----------------------------------------------------------------------------------------------------------------
-- Hotel
DROP TABLE IF EXISTS group_02.victoriahotel;
CREATE TABLE group_02.victoriahotel (
    HotelID INTEGER,
    HotelName CHARACTER VARYING,
    Latitude float(10),
    Longitude float(10),
    PRIMARY KEY (HotelID)
);
SELECT addGeometryColumn('group_02',
                        'victoriahotel',
                        'geom',
                        4326,
                        'POINT',
                        2);
UPDATE group_02.victoriahotel SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

----------------------------------------------------------------------------------------------------------------
-- Operator
DROP TABLE IF EXISTS group_02.Operator;
CREATE TABLE group_02.Operator (
    OperatorID INTEGER,
    License BOOLEAN,
    Qualification CHARACTER VARYING,
    FlightHours TIME WITHOUT TIME ZONE,
    ContactNumber CHARACTER VARYING,
    Email CHARACTER VARYING,
    PRIMARY KEY(OperatorID)
);

----------------------------------------------------------------------------------------------------------------
-- Parks
DROP TABLE IF EXISTS group_02.victoriapark;
CREATE TABLE group_02.victoriapark AS
SELECT vpa_id, park_name, geom
FROM group_02.park W
WHERE os_type = 'Public open space' AND os_access = 'Open' AND os_categor = 'Parks and gardens';

ALTER TABLE group_02.victoriapark ADD PRIMARY KEY (vpa_id);

----------------------------------------------------------------------------------------------------------------
-- Sensor
CREATE TABLE group_02.Sensor (
    SensorID INTEGER,
    SensorType CHARACTER VARYING,
    LastCalibrationDate DATE,
    MaxAltitude NUMERIC,
    SensorWeight NUMERIC,
    PRIMARY KEY (SensorID)
);

----------------------------------------------------------------------------------------------------------------
-- Training
CREATE TABLE group_02.Training (
    TrainingID INTEGER,
    OperatorID INTEGER,
    TrainingDate DATE,
    PRIMARY KEY (TrainingID)
);

----------------------------------------------------------------------------------------------------------------
-- Unimelb campus
DROP TABLE IF EXISTS group_02.unimelbcampus;
CREATE TABLE group_02.UniMelbCampus (
    ClusterID INTEGER,
    CampusName CHARACTER VARYING,
    CampusCluster CHARACTER VARYING,
    PRIMARY KEY (ClusterID)
);
SELECT addGeometryColumn('group_02',
                        'unimelbcampus',
                        'ClusterLocation',
                        4326,
                        'MULTIPOLYGON',
                        2);

--==============================================================================================================
-- The following code can be run to generate foreign key constraints
--==============================================================================================================
-- Operator.OperatorID = Training.OperatorID
ALTER TABLE group_02.Training
ADD CONSTRAINT FK_OperatorID_in_Training
FOREIGN KEY (OperatorID)
REFERENCES group_02.Operator (OperatorID);

-- Operator.OperatorID = FlightPlan.OperatorID
ALTER TABLE group_02.FlightPlan
ADD CONSTRAINT FK_OperatorID_in_FlightPlan
FOREIGN KEY (OperatorID)
REFERENCES group_02.Operator (OperatorID);

-- FlightPath.PathID = FlightPlan.ID
ALTER TABLE group_02.FlightPlan
ADD CONSTRAINT FK_PathID_in_FlightPlan
FOREIGN KEY (PathID)
REFERENCES group_02.FlightPath (PathID);

-- Drone.DroneID = FlightPlan.DroneID
ALTER TABLE group_02.FlightPlan
ADD CONSTRAINT FK_DroneID_in_FlightPlan
FOREIGN KEY (DroneID)
REFERENCES group_02.Drone (DroneID);

-- Sensor.SensorID = Drone.SensorID
ALTER TABLE group_02.Drone
ADD CONSTRAINT FK_SensorID_in_Drone
FOREIGN KEY (SensorID)
REFERENCES group_02.Sensor (SensorID);

-- Battery.BatteryID = Drone.BatteryID
ALTER TABLE group_02.Drone
ADD CONSTRAINT FK_BatteryID_in_Drone
FOREIGN KEY (BatteryID)
REFERENCES group_02.Battery (BatteryID);

--==============================================================================================================
-- The following code can be run to implement autogenerated columns triggers
--==============================================================================================================
-- The following trigger populates the closeByHospital column in flightplan 
CREATE OR REPLACE FUNCTION automate_close_by_place()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
DECLARE
	hospital_name CHARACTER VARYING;
BEGIN

	-- Query to find nearest hospital from start point of the path in the plan
	SELECT hospital.hospitalname INTO hospital_name
	FROM group_02.victoriahospital as hospital 
    JOIN group_02.flightpath p ON p.pathid = NEW.pathid
	ORDER BY p.startpoint<-> ST_Transform(hospital.geom, 4326)
	LIMIT 1;
	
    NEW.closeByHospital := hospital_name;
    RETURN NEW;
END;
$function$;

-- Create a trigger on the FlightPlan table
CREATE TRIGGER automate_close_by_place_trigger
BEFORE INSERT OR UPDATE ON group_02.flightplan
FOR EACH ROW
EXECUTE FUNCTION automate_close_by_place();

----------------------------------------------------------------------------------------------------------------
-- The following trigger populates the flightend column in flightplan
CREATE OR REPLACE FUNCTION automate_flightplan_flightend()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
DECLARE
    max_flight_time interval;
BEGIN
    -- Calculate flight time
    SELECT (ST_Length((
        SELECT geom
        FROM group_02.flightpath
        WHERE pathid = NEW.pathid
        )::geography) / 1000 / (
            SELECT avgspeed 
            FROM group_02.drone 
            WHERE droneid = NEW.droneid
            )) * INTERVAL '1 hour' INTO max_flight_time;

    -- Calculate the flight end time
    NEW.flightend := NEW.flightstart + max_flight_time;

    RETURN NEW;
END;
$function$;

-- Create a trigger on the FlightPlan table
CREATE TRIGGER automate_flightplan_flightend_trigger
BEFORE INSERT OR UPDATE
ON group_02.flightplan
FOR EACH ROW
EXECUTE FUNCTION automate_flightplan_flightend();

----------------------------------------------------------------------------------------------------------------
-- The following trigger populates the startpoint column in flightpath
CREATE OR REPLACE FUNCTION automate_flightpath_startpoint()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Assign start point of flight path
    NEW.startpoint := ST_Force2D(ST_StartPoint(NEW.geom));
    RETURN NEW;
END;
$function$;

-- Create a trigger on the FlightPlan table
CREATE TRIGGER automate_flightpath_startpoint_trigger
BEFORE INSERT OR UPDATE ON group_02.flightpath
FOR EACH ROW
EXECUTE FUNCTION automate_flightpath_startpoint();

----------------------------------------------------------------------------------------------------------------
-- The following trigger populates the MaxElev, MinElev and DiffElev columns in flightpath
CREATE OR REPLACE FUNCTION automate_path_elevation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $function$
DECLARE
    max_elev numeric;
	min_elev numeric;
BEGIN
	-- Elevation of flight path (Z of geom) is above ground elevation
	-- Elevation of raster in DEM is above sea level elevation
	-- Hence, max/min elevation above sea level of the flight path is its sum
	
	SELECT ST_ZMax(NEW.geom) + MAX((ST_SummaryStats(ST_Clip(rast, ST_Transform(NEW.geom, 7855)))).max)
  	FROM group_02.victoriadem WHERE ST_Intersects(rast, ST_Transform(NEW.geom, 7855))
	INTO max_elev;
		   
	SELECT ST_ZMin(NEW.geom) + MIN((ST_SummaryStats(ST_Clip(rast, ST_Transform(NEW.geom, 7855)))).min)
	FROM group_02.victoriadem WHERE ST_Intersects(rast, ST_Transform(NEW.geom, 7855)) 
	INTO min_elev;
	
    NEW.MaxElev := max_elev;
	NEW.MinElev := min_elev;
	NEW.DiffElev := max_elev - min_elev;

    RETURN NEW;
END;
$function$;

-- Create a trigger on the FlightPath table
CREATE TRIGGER automate_path_elevation_trigger
BEFORE INSERT OR UPDATE
ON group_02.flightpath
FOR EACH ROW
EXECUTE FUNCTION automate_path_elevation();

--==============================================================================================================
-- The following code can be run to insert data into the tables
--==============================================================================================================
-- SPATIAL TABLES: Open Sourced or from Spatial Schema
--==============================================================================================================
-- NOTE: VictoriaAirports, VictoriaBeach and VictoriaHelipads do not have table population code as this was done by exporting shape files
----------------------------------------------------------------------------------------------------------------
-- Hospitals
-- INSERT INTO group_02.Hospital VALUES (1,'WESTERN DISTRICT HEALTH SERVICE - HAMILTON',-37.736495,142.030606,'Public'),(2,'WESTERN DISTRICT HEALTH SERVICE - PENSHURST',-37.877275,142.282487,'Public'),(3,'COLAC AREA HEALTH',-38.341201,143.582854,'Public'),(4,'HESSE RURAL HEALTH SERVICE',-38.243369,143.985357,'Public'),(5,'GREAT OCEAN ROAD HEALTH - OTWAY HEALTH',-38.753853,143.664264,'Public'),(6,'BARWON HEALTH - GEELONG HOSPITAL CAMPUS',-38.151533,144.364964,'Public'),(7,'CASTERTON MEMORIAL HOSPITAL',-37.589989,141.392283,'Public'),(8,'WESTERN DISTRICT HEALTH SERVICE - COLERAINE',-37.604049,141.686038,'Public'),(9,'SOUTH WEST HEALTHCARE - WARRNAMBOOL CAMPUS',-38.380085,142.472977,'Public'),(10,'BEAUFORT & SKIPTON HEALTH SERVICES - SKIPTON CAMPUS',-37.683998,143.367547,'Public'),(11,'HEYWOOD RURAL HEALTH',-38.137788,141.624256,'Public'),(12,'TIMBOON & DISTRICT HEALTHCARE SERVICE',-38.486231,142.976717,'Public'),(13,'MOYNE HEALTH SERVICES',-38.381599,142.227523,'Public'),(14,'PORTLAND DISTRICT HEALTH',-38.340713,141.606087,'Public'),(15,'GREAT OCEAN ROAD HEALTH - LORNE COMMUNITY HOSPITAL',-38.545513,143.980743,'Public'),(16,'BARWON HEALTH - MCKELLAR CENTRE CAMPUS',-38.118795,144.335728,'Public'),(17,'SOUTH WEST HEALTHCARE - CAMPERDOWN',-38.237101,143.137714,'Public'),(18,'TERANG & MORTLAKE HEALTH SERVICE',-38.239388,142.902119,'Public'),(19,'EAST GRAMPIANS HEALTH SERVICE - ARARAT',-37.278816,142.932858,'Public'),(20,'EAST GRAMPIANS HEALTH SERVICE - WILLAURA CAMPUS',-37.544798,142.74587,'Public'),(21,'RURAL NORTHWEST HEALTH - WARRACKNABEAL CAMPUS',-36.252614,142.381609,'Public'),(22,'RURAL NORTHWEST HEALTH - HOPETOUN CAMPUS',-35.732201,142.366411,'Public'),(23,'BALLARAT HEALTH SERVICES (BASE HOSPITAL)',-37.559658,143.847041,'Public'),(24,'BALLARAT HEALTH SERVICES - QUEEN ELIZABETH CENTRE',-37.564276,143.843264,'Public'),(25,'WIMMERA HEALTH CARE GROUP - HORSHAM',-36.712441,142.208522,'Public'),(26,'DUNMUNKLE HEALTH SERVICES',-36.636571,142.631849,'Public'),(27,'STAWELL REGIONAL HEALTH',-37.059577,142.781603,'Public'),(28,'WEST WIMMERA HEALTH SERVICE - NHILL',-36.334003,141.655579,'Public'),(29,'WEST WIMMERA HEALTH SERVICE - KANIVA',-36.381386,141.246006,'Public'),(30,'WEST WIMMERA HEALTH SERVICE - JEPARIT',-36.141132,141.984686,'Public'),(31,'WEST WIMMERA HEALTH SERVICE - RAINBOW',-35.903874,141.995112,'Public'),(32,'EAST WIMMERA HEALTH SERVICE - ST ARNAUD',-36.609275,143.246676,'Public'),(33,'DJERRIWARRH HEALTH SERVICE - BACCHUS MARSH',-37.678267,144.433264,'Public'),(34,'BEAUFORT & SKIPTON HEALTH SERVICES - BEAUFORT CAMPUS',-37.431028,143.382284,'Public'),(35,'WIMMERA HEALTH CARE GROUP - DIMBOOLA',-36.449887,142.024286,'Public'),(36,'EDENHOPE AND DISTRICT MEMORIAL HOSPITAL',-37.035323,141.288829,'Public'),(37,'CENTRAL HIGHLANDS RURALY HEALTH - DAYLESFORD',-37.337365,144.145774,'Public'),(38,'CENTRAL HIGHLANDS RURAL HEALTH - CRESWICK',-37.421192,143.891533,'Public'),(39,'BENDIGO HEALTH CARE GROUP - BENDIGO HOSPITAL',-36.748727,144.283372,'Public'),(40,'BENDIGO HEALTH CARE GROUP - ANNE CAUDLE CAMPUS',-36.750919,144.280399,'Public'),(41,'GOULBURN VALLEY HEALTH - WARANGA CAMPUS',-36.587827,145.008593,'Public'),(42,'KYABRAM & DISTRICT HEALTH SERVICES',-36.315539,145.042705,'Public'),(43,'CENTRAL HIGHLANDS RURAL HEALTH -KYNETON',-37.254431,144.469742,'Public'),(44,'HEATHCOTE HEALTH',-36.925786,144.709499,'Public'),(45,'MARYBOROUGH DISTRICT HEALTH SERVICE (MARYBOROUGH)',-37.044781,143.737692,'Public'),(46,'MARYBOROUGH DISTRICT HEALTH SERVICE (DUNOLLY)',-36.855269,143.735139,'Public'),(47,'SWAN HILL DISTRICT HEALTH [SWAN HILL]',-35.340588,143.556514,'Public'),(48,'SWAN HILL DISTRICT HEALTH [NYAH]',-35.186052,143.355428,'Public'),(49,'EAST WIMMERA HEALTH SERVICE - WYCHEPROOF',-36.078447,143.233779,'Public'),(50,'COHUNA DISTRICT HOSPITAL',-35.800063,144.214911,'Public'),(51,'ECHUCA REGIONAL HEALTH',-36.138186,144.748369,'Public'),(52,'KERANG DISTRICT HEALTH',-35.724201,143.917848,'Public'),(53,'MILDURA BASE HOSPITAL',-34.186038,142.143679,'Public'),(54,'MALLEE TRACK HEALTH AND COMMUNITY SERVICE',-35.074349,142.312345,'Public'),(55,'MALDON HOSPITAL',-36.992672,144.063677,'Public'),(56,'ROBINVALE DISTRICT HEALTH SERVICES - MANANGATANG CAMPUS',-35.050955,142.880512,'Public'),(57,'BOORT DISTRICT HEALTH',-36.111703,143.727285,'Public'),(58,'ROBINVALE DISTRICT HEALTH SERVICES - ROBINVALE CAMPUS',-34.584146,142.781367,'Public'),(59,'ROCHESTER AND ELMORE DISTRICT HEALTH SERVICE',-36.366579,144.697751,'Public'),(60,'EAST WIMMERA HEALTH SERVICE - DONALD',-36.366895,142.976583,'Public'),(61,'INGLEWOOD AND DISTRICT HEALTH SERVICE',-36.572147,143.873755,'Public'),(62,'EAST WIMMERA HEALTH SERVICE - BIRCHIP',-35.980167,142.915891,'Public'),(63,'EAST WIMMERA HEALTH SERVICE - CHARLTON',-36.271037,143.345889,'Public'),(64,'CASTLEMAINE HEALTH',-37.052539,144.212315,'Public'),(65,'SEA LAKE & DISTRICT HOSPITAL',-35.500637,142.857968,'Public'),(66,'GOULBURN VALLEY HEALTH - SHEPPARTON CAMPUS',-36.363625,145.404911,'Public'),(67,'GOULBURN VALLEY HEALTH - TATURA CAMPUS',-36.439082,145.225535,'Public'),(68,'NORTHEAST HEALTH WANGARATTA',-36.354035,146.313889,'Public'),(69,'TALLANGATTA HEALTH SERVICE',-36.213705,147.183709,'Public'),(70,'ALBURY WODONGA HEALTH - WODONGA CAMPUS',-36.131791,146.879417,'Public'),(71,'YARRAWONGA HEALTH',-36.011547,146.006584,'Public'),(72,'ALPINE HEALTH (MYRTLEFORD)',-36.554525,146.728795,'Public'),(73,'ALPINE HEALTH (BRIGHT)',-36.732701,146.965924,'Public'),(74,'ALPINE HEALTH (MOUNT BEAUTY)',-36.743354,147.169359,'Public'),(75,'UPPER MURRAY HEALTH AND COMMUNITY SERVICES',-36.198711,147.902798,'Public'),(76,'SEYMOUR HEALTH',-37.018384,145.138771,'Public'),(77,'MANSFIELD DISTRICT HOSPITAL',-37.057574,146.086149,'Public'),(78,'ALEXANDRA DISTRICT HOSPITAL',-37.195065,145.716143,'Public'),(79,'NUMURKAH DISTRICT HEALTH SERVICE',-36.100001,145.443695,'Public'),(80,'THE KILMORE AND DISTRICT HOSPITAL',-37.301794,144.957915,'Public'),(81,'YEA AND DISTRICT MEMORIAL HOSPITAL',-37.213634,145.430724,'Public'),(82,'NATHALIA DISTRICT HOSPITAL',-36.054754,145.204324,'Public'),(83,'BENALLA HEALTH',-36.555239,145.994675,'Public'),(84,'BEECHWORTH HEALTH SERVICE',-36.349359,146.690739,'Public'),(85,'COBRAM DISTRICT HEALTH',-35.916273,145.651029,'Public'),(86,'BAIRNSDALE REGIONAL HEALTH SERVICE',-37.83171,147.608239,'Public'),(87,'WEST GIPPSLAND HEALTHCARE GROUP',-38.173009,145.926804,'Public'),(88,'BASS COAST REGIONAL HEALTH',-38.608747,145.580906,'Public'),(89,'YARRAM & DISTRICT HEALTH SERVICE',-38.556975,146.678316,'Public'),(90,'OMEO DISTRICT HEALTH',-37.098142,147.597321,'Public'),(91,'CENTRAL GIPPSLAND HEALTH SERVICE (SALE)',-38.108408,147.080637,'Public'),(92,'GIPPSLAND SOUTHERN HEALTH SERVICE - KORUMBURRA CAMPUS',-38.430328,145.828249,'Public'),(93,'GIPPSLAND SOUTHERN HEALTH SERVICE - LEONGATHA CAMPUS',-38.487171,145.950343,'Public'),(94,'LATROBE REGIONAL HOSPITAL',-38.218475,146.471335,'Public'),(95,'CENTRAL GIPPSLAND HEALTH SERVICE (MAFFRA)',-37.961032,146.983487,'Public'),(96,'SOUTH GIPPSLAND HOSPITAL',-38.658319,146.207031,'Public'),(97,'ORBOST REGIONAL HEALTH',-37.701844,148.464957,'Public'),(98,'BOX HILL HOSPITAL',-37.813682,145.119094,'Public'),(99,'MONASH MEDICAL CENTRE - CLAYTON CAMPUS',-37.921176,145.123128,'Public'),(100,'MAROONDAH HOSPITAL',-37.806884,145.254535,'Public'),(101,'ANGLISS HOSPITAL',-37.898663,145.314166,'Public'),(102,'ST GEORGES HEALTH SERVICE',-37.809085,145.052585,'Public'),(103,'CARITAS CHRISTI HOSPICE',-37.804706,145.015557,'Public'),(104,'MERCY HEALTH - OCONNELL FAMILY CENTRE CAMPUS',-37.816688,145.061729,'Public'),(105,'PETER JAMES CENTRE',-37.852712,145.164542,'Public'),(106,'WANTIRNA HEALTH',-37.848525,145.225902,'Public'),(107,'ROYAL TALBOT REHABILITATION CENTRE',-37.789522,145.023715,'Public'),(108,'HEALESVILLE & DISTRICT HOSPITAL',-37.646879,145.529032,'Public'),(109,'YARRA RANGES HEALTH',-37.756319,145.351204,'Public'),(110,'MONASH MEDICAL CENTRE - MOORABBIN CAMPUS',-37.920697,145.063197,'Public'),(111,'ROSEBUD HOSPITAL',-38.362168,144.884899,'Public'),(112,'SANDRINGHAM HOSPITAL',-37.961049,145.018157,'Public'),(113,'CAULFIELD HOSPITAL',-37.882707,145.016892,'Public'),(114,'KOOWEERUP REGIONAL HEALTH SERVICE',-38.200653,145.484433,'Public'),(115,'KINGSTON CENTRE',-37.955018,145.078969,'Public'),(116,'DANDENONG HOSPITAL',-37.976459,145.218529,'Public'),(117,'CRANBOURNE INTEGRATED CARE CENTRE',-38.113312,145.280832,'Public'),(118,'FRANKSTON HOSPITAL',-38.150791,145.128428,'Public'),(119,'CALVARY HEALTH CARE BETHLEHEM',-37.990709,145.072532,'Public'),(120,'THE QUEEN ELIZABETH CENTRE',-37.972053,145.178285,'Public'),(121,'CASEY HOSPITAL',-38.045325,145.347181,'Public'),(122,'GOLF LINKS ROAD REHABILITATION CENTRE',-38.173447,145.149769,'Public'),(123,'THE MORNINGTON CENTRE',-38.230174,145.041697,'Public'),(124,'THE ALFRED',-37.846087,144.981937,'Public'),(125,'AUSTIN HEALTH - AUSTIN HOSPITAL',-37.756355,145.060236,'Public'),(126,'AUSTIN HEALTH - HEIDELBERG REPATRIATION HOSPITAL',-37.755973,145.04749,'Public'),(127,'BUNDOORA EXTENDED CARE CENTRE',-37.701124,145.055569,'Public'),(128,'MERCY HOSPITAL FOR WOMEN',-37.756075,145.061008,'Public'),(129,'WESTERN HOSPITAL',-37.792298,144.887191,'Public'),(130,'THE ROYAL CHILDRENS HOSPITAL',-37.794997,144.950859,'Public'),(131,'THE ROYAL WOMENS HOSPITAL',-37.798772,144.954825,'Public'),(132,'WOMENS AT SANDRINGHAM',-37.961369,145.01859,'Public'),(133,'THE ROYAL VICTORIAN EYE AND EAR HOSPITAL',-37.808978,144.976245,'Public'),(134,'THE NORTHERN HOSPITAL',-37.653417,145.014381,'Public'),(135,'WERRIBEE MERCY HOSPITAL',-37.886587,144.698621,'Public'),(136,'URSULA FRAYNE CENTRE',-37.79168,144.88721,'Public'),(137,'ORYGEN INPATIENT UNIT',-37.791926,144.886617,'Public'),(138,'ROYAL MELBOURNE HOSPITAL - CITY CAMPUS',-37.799259,144.956864,'Public'),(139,'ROYAL MELBOURNE HOSPITAL - ROYAL PARK CAMPUS',-37.778813,144.948049,'Public'),(140,'SUNSHINE HOSPITAL',-37.759179,144.816477,'Public'),(141,'ST VINCENTS HOSPITAL (MELBOURNE) LTD',-37.807377,144.97523,'Public'),(142,'WILLIAMSTOWN HOSPITAL',-37.863576,144.892339,'Public'),(143,'PETER MACCALLUM CANCER CENTRE',-37.811589,144.977372,'Public'),(144,'TWEDDLE CHILD AND FAMILY HEALTH SERVICE',-37.797407,144.887421,'Public'),(145,'SUNBURY DAY HOSPITAL',-37.562609,144.715648,'Public'),(146,'BROADMEADOWS HEALTH SERVICE',-37.684321,144.913106,'Public'),(147,'CRAIGIEBURN HEALTH SERVICE',-37.596042,144.918888,'Public'),(148,'DJERRIWARRH HEALTH SERVICES - MELTON HEALTH',-37.686449,144.558284,'Public'),(149,'DENTAL HEALTH SERVICES VICTORIA',-37.799299,144.964529,'Public'),(150,'THOMAS EMBLING HOSPITAL',-37.78931,145.012975,'Public'),(151,'ST VINCENTS PRIVATE HOSPITAL EAST MELBOURNE',-37.811984,144.984003,'Private'),(152,'VISION DAY SURGERY CAMBERWELL',-37.832535,145.055602,'Private'),(153,'DANDENONG EYE CLINIC & DAY SURGERY CENTRE',-37.974247,145.2233,'Private'),(154,'THE DIGESTIVE HEALTH CENTRE',-37.977247,145.216663,'Private'),(155,'VISION DAY SURGERY FOOTSCRAY',-37.800523,144.895149,'Private'),(156,'ALTONA ENDOSCOPY CENTRE',-37.869077,144.828504,'Private'),(157,'HEIDELBERG ENDOSCOPY AND DAY SURGERY CENTRE',-37.730524,145.060247,'Private'),(158,'IVANHOE ENDOSCOPY CENTRE',-37.767059,145.044921,'Private'),(159,'JOLIMONT ENDOSCOPY',-37.816594,144.978413,'Private'),(160,'MELBOURNE ENDOSCOPY',-37.844601,144.97932,'Private'),(161,'MELBOURNE ENDOSCOPY MONASH DAY PROCEDURE CENTRE',-37.921485,145.120275,'Private'),(162,'MELBOURNE DAY SURGERY CENTRE',-37.887848,145.030378,'Private'),(163,'NOBLE PARK ENDOSCOPY CENTRE',-37.967089,145.189701,'Private'),(164,'NORTHWEST DAY HOSPITAL',-37.771181,144.909389,'Private'),(165,'WINDSOR PRIVATE HOSPITAL',-37.856118,144.998213,'Private'),(166,'CHESTERVILLE DAY HOSPITAL',-37.96046,145.0568,'Private'),(167,'SOUTHERN EYE CENTRE, DAY SURGERY & LASER CLINIC',-38.146041,145.132023,'Private'),(168,'SPRINGVALE ENDOSCOPY CENTRE AND DAY HOSPITAL',-37.949257,145.149999,'Private'),(169,'MARIE STOPES MAROONDAH',-37.808695,145.288737,'Private'),(170,'WAVERLEY ENDOSCOPY',-37.880341,145.146512,'Private'),(171,'WESTERN GASTROENTEROLOGY SERVICES',-37.792007,144.885378,'Private'),(172,'KEILOR PRIVATE',-37.719721,144.834483,'Private'),(173,'VISION DAY SURGERY EASTERN',-37.817747,145.119492,'Private'),(174,'ALBERT ROAD CLINIC',-37.834246,144.972151,'Private'),(175,'BALLAN DISTRICT HEALTH & CARE',-37.599338,144.222001,'Private'),(176,'ESSENDON PRIVATE CLINIC',-37.748615,144.885413,'Private'),(177,'BELEURA PRIVATE HOSPITAL',-38.225484,145.049136,'Private'),(178,'THE GEELONG CLINIC',-38.182406,144.393267,'Private'),(179,'BELLBIRD PRIVATE HOSPITAL',-37.833073,145.156018,'Private'),(180,'ST JOHN OF GOD BERWICK HOSPITAL',-38.034499,145.344974,'Private'),(181,'CABRINI BRIGHTON',-37.91165,144.991572,'Private'),(182,'EPWORTH REHABILITATION BRIGHTON',-37.913689,145.002815,'Private'),(183,'EPWORTH CAMBERWELL',-37.846223,145.054689,'Private'),(184,'EPWORTH CLIVEDEN',-37.815662,144.987547,'Private'),(185,'HOLMESGLEN PRIVATE HOSPITAL',-37.935405,145.050068,'Private'),(186,'ST JOHN OF GOD PINELODGE CLINIC',-37.970226,145.213143,'Private'),(187,'DELMONT PRIVATE HOSPITAL',-37.856889,145.09407,'Private'),(188,'DIAMOND VALLEY RENAL CARE CENTRE',-37.705436,145.10754,'Private'),(189,'DONVALE REHABILITATION HOSPITAL',-37.789836,145.171655,'Private'),(190,'DORSET REHABILITATION CENTRE',-37.723402,144.947436,'Private'),(191,'CABRINI ELSTERNWICK REHABILITATION',-37.88543,145.009328,'Private'),(192,'EPWORTH RICHMOND',-37.817433,144.993029,'Private'),(193,'EUROA HEALTH',-36.759232,145.570468,'Private'),(194,'FRANCES PERRY HOUSE',-37.798758,144.955135,'Private'),(195,'EPWORTH FREEMASONS',-37.810394,144.984065,'Private'),(196,'HEYFIELD HOSPITAL INC',-37.976359,146.783996,'Private'),(197,'CABRINI HOPETOUN REHABILITATION',-37.884778,145.01039,'Private'),(198,'NORTH EASTERN REHABILITATION CENTRE',-37.763424,145.031344,'Private'),(199,'JESSIE MCPHERSON PRIVATE HOSPITAL',-37.919968,145.123327,'Private'),(200,'KNOX PRIVATE HOSPITAL',-37.849645,145.228035,'Private'),(201,'LA TROBE PRIVATE HOSPITAL',-37.716965,145.044143,'Private'),(202,'LINACRE PRIVATE HOSPITAL',-37.942699,145.003259,'Private'),(203,'MALVERN PRIVATE HOSPITAL',-37.867197,145.06088,'Private'),(204,'MARYVALE PRIVATE HOSPITAL',-38.215028,146.418561,'Private'),(205,'MASADA PRIVATE HOSPITAL',-37.869799,145.003096,'Private'),(206,'MELBOURNE PRIVATE HOSPITAL',-37.798272,144.957025,'Private'),(207,'MILDURA HEALTH PRIVATE HOSPITAL',-34.18479,142.145705,'Private'),(208,'MITCHAM PRIVATE HOSPITAL',-37.810436,145.194808,'Private'),(209,'MONASH SURGICAL PRIVATE HOSPITAL',-37.921917,145.120554,'Private'),(210,'ST JOHN OF GOD BENDIGO HOSPITAL',-36.762043,144.263298,'Private'),(211,'THE MELBOURNE EASTERN PRIVATE HOSPITAL',-37.855491,145.268279,'Private'),(212,'MURRAY VALLEY PRIVATE HOSPITAL',-36.138419,146.876478,'Private'),(213,'NAGAMBIE HOSPITAL INC',-36.780976,145.150273,'Private'),(214,'NEERIM DISTRICT HEALTH SERVICE',-38.021988,145.953863,'Private'),(215,'NORTHPARK PRIVATE HOSPITAL',-37.691208,145.061631,'Private'),(216,'PENINSULA PRIVATE HOSPITAL (VIC)',-38.157557,145.169552,'Private'),(217,'RESERVOIR PRIVATE HOSPITAL DAY PROCEDURE CENTRE',-37.717623,144.998009,'Private'),(218,'RINGWOOD PRIVATE HOSPITAL',-37.811523,145.243629,'Private'),(219,'SHEPPARTON PRIVATE HOSPITAL',-36.359183,145.410825,'Private'),(220,'SIR JOHN MONASH PRIVATE HOSPITAL',-37.920503,145.122351,'Private'),(221,'SOUTH EASTERN PRIVATE HOSPITAL',-37.966243,145.191922,'Private'),(222,'CABRINI MALVERN',-37.861641,145.0335,'Private'),(223,'ST JOHN OF GOD BALLARAT HOSPITAL',-37.558544,143.847406,'Private'),(224,'ST JOHN OF GOD GEELONG HOSPITAL',-38.151567,144.357679,'Private'),(225,'ST JOHN OF GOD WARRNAMBOOL HOSPITAL',-38.371405,142.478749,'Private'),(226,'ST VINCENTS PRIVATE HOSPITAL FITZROY',-37.806545,144.975231,'Private'),(227,'THE AVENUE PRIVATE HOSPITAL',-37.854809,144.998513,'Private'),(228,'THE MELBOURNE CLINIC',-37.814361,144.998739,'Private'),(229,'MULGRAVE PRIVATE HOSPITAL',-37.938724,145.211559,'Private'),(230,'BRUNSWICK PRIVATE HOSPITAL',-37.756737,144.972206,'Private'),(231,'THE VICTORIA CLINIC',-37.847714,144.997225,'Private'),(232,'THE VICTORIAN REHABILITATION CENTRE',-37.898227,145.161425,'Private'),(233,'ST VINCENTS PRIVATE HOSPITAL KEW',-37.806549,145.02402,'Private'),(234,'WANGARATTA PRIVATE HOSPITAL',-36.349299,146.312423,'Private'),(235,'WARRINGAL PRIVATE HOSPITAL',-37.754419,145.060728,'Private'),(236,'WAVERLEY PRIVATE HOSPITAL',-37.884632,145.145798,'Private'),(237,'WESTERN PRIVATE HOSPITAL',-37.793045,144.885932,'Private'),(238,'CABRINI PRAHRAN',-37.854296,145.008874,'Private'),(239,'JOHN FAWKNER PRIVATE HOSPITAL',-37.754369,144.958398,'Private'),(240,'BAYSIDE ENDOSCOPY DAY HOSPITAL',-37.932969,145.036555,'Private'),(241,'MARIE STOPES EAST ST KILDA',-37.860148,145.007719,'Private'),(242,'FERTILITY CONTROL CLINIC',-37.816255,144.98617,'Private'),(243,'ST ALBANS ENDOSCOPY CENTRE',-37.744072,144.77935,'Private'),(244,'ST JOHN OF GOD FRANKSTON REHABILITATION HOSPITAL',-38.153035,145.155926,'Private'),(245,'STONNINGTON DAY SURGERY',-37.863691,145.03938,'Private'),(246,'SUNSHINE PRIVATE DAY SURGERY',-37.761122,144.816349,'Private'),(247,'BAYSIDE DAY PROCEDURE AND SPECIALIST CENTRE',-38.148273,145.143358,'Private'),(248,'THE GLEN ENDOSCOPY CENTRE',-37.884643,145.165114,'Private'),(249,'EASTSIDE ENDOSCOPY CENTRE',-37.819779,145.227494,'Private'),(250,'BALLARAT DAY PROCEDURE CENTRE',-37.540817,143.83215,'Private'),(251,'FOREST HILL DIALYSIS CLINIC',-37.836285,145.16648,'Private'),(252,'DAREBIN ENDOSCOPY SERVICES',-37.781099,145.017567,'Private'),(253,'COBURG ENDOSCOPY CENTRE',-37.745009,144.96486,'Private'),(254,'BAYSWATER DAY PROCEDURE AND SPECIALIST CENTRE',-37.841851,145.263014,'Private'),(255,'KEW ENDOSCOPY CENTRE',-37.794491,145.062495,'Private'),(256,'SPECIALIST SURGICENTRE DOCKLANDS',-37.814605,144.941254,'Private'),(257,'MALVERN DIALYSIS CLINIC',-37.851421,145.030679,'Private'),(258,'TOORAK-MALVERN DAY SURGERY CENTRE',-37.863945,145.028189,'Private'),(259,'GLENFERRIE PRIVATE HOSPITAL',-37.819459,145.031544,'Private'),(260,'ST KILDA DAY HOSPITAL',-37.873088,144.982227,'Private'),(261,'EPWORTH EASTERN HOSPITAL (1 of 3 campuses)',-37.814678,145.119368,'Private'),(262,'MANNINGHAM DAY PROCEDURE CENTRE',-37.773471,145.115635,'Private'),(263,'SPECIALIST SURGICENTRE GEELONG',-38.149049,144.366075,'Private'),(264,'BENTLEIGH SURGICENTRE',-37.920241,145.041123,'Private'),(265,'VICTORIA PARADE SURGERY CENTRE',-37.808521,144.97476,'Private'),(266,'WERRIBEE ENDOSCOPY CENTRE',-37.890464,144.686742,'Private'),(267,'FRANKSTON PRIVATE HOSPITAL',-38.1543,145.133382,'Private'),(268,'HAMPTON PARK WOMENS HEALTH CLINIC',-38.031698,145.268483,'Private'),(269,'WESTPOINT ENDOSCOPY DAY HOSPITAL',-37.87747,144.679744,'Private'),(270,'VICTORIA GUT CENTRE BUNDOORA',-37.692463,145.062044,'Private'),(271,'GLEN EIRA DAY SURGERY',-37.900227,145.019193,'Private'),(272,'ESSENDON DAY PROCEDURE CENTRE',-37.765499,144.923165,'Private'),(273,'HYPERBARIC HEALTH',-38.034441,145.344808,'Private'),(274,'CORYMBIA DAY HOSPITAL',-37.97724,145.21706,'Private'),(275,'BENDIGO DAY SURGERY',-36.761815,144.261582,'Private'),(276,'BERWICK SURGICENTRE',-38.033667,145.346487,'Private'),(277,'MELBOURNE MEDIBRAIN CENTRE AND MEDISLEEP',-37.869064,145.018774,'Private'),(278,'THE BAYS HOSPITAL (1 of 2 campuses)',-38.223381,145.041968,'Private'),(279,'GLEN IRIS PRIVATE',-37.858058,145.09363,'Private'),(280,'NORTH MELBOURNE RENAL CARE CENTRE',-37.788626,144.940111,'Private'),(281,'SKIN CANCER DAY SURGERY',-37.86818,145.105371,'Private'),(282,'EAST MELBOURNE SPECIALIST DAY HOSPITAL',-37.809953,144.983482,'Private'),(283,'SYDENHAM DAY SURGERY',-37.693202,144.758635,'Private'),(284,'HYPERBARIC HEALTH WOUND CENTRE BUNDOORA',-37.716518,145.044114,'Private'),(285,'EPWORTH HAWTHORN',-37.82126,145.02293,'Private'),(286,'GOONAWARRA DAY HOSPITAL',-37.579743,144.749668,'Private'),(287,'WINDSOR AVENUE DAY SURGERY',-37.951812,145.14949,'Private'),(288,'IMAGING @ OLYMPIC PARK',-37.824124,144.984319,'Private'),(289,'CASEY DAY PROCEDURE AND SPECIALIST CENTRE',-38.02487,145.314422,'Private'),(290,'THE VICTORIAN COSMETIC INSTITUTE',-38.032668,145.343226,'Private'),(291,'WYNDHAM CLINIC',-37.886048,144.700626,'Private'),(292,'SKIN & CANCER FOUNDATION INC',-37.804888,144.968609,'Private'),(293,'MORNINGTON ENDOSCOPY',-38.227684,145.044105,'Private'),(294,'CHELSEA HEIGHTS DAY SURGERY AND ENDOSCOPY',-38.033206,145.134586,'Private'),(295,'ST JOHN OF GOD BERWICK DAY ONCOLOGY CENTRE',-38.04538,145.344956,'Private'),(296,'BALLARAT SURGICENTRE',-37.542901,143.852263,'Private'),(297,'PANCH DAY SURGERY CENTRE',-37.746753,145.008164,'Private'),(298,'DR SCOPE',-37.777691,144.832523,'Private'),(299,'EPWORTH GEELONG',-38.204394,144.298195,'Private'),(300,'MONASH HOUSE PRIVATE HOSPITAL',-37.920919,145.120318,'Private'),(301,'GENESIS CARE RADIATION ONCOLOGY CENTRE ST VINCENTS HOSPITAL MELBOURNE',-37.807546,144.975049,'Private'),(302,'VERMONT PRIVATE HOSPITAL',-37.858587,145.199527,'Private'),(303,'FRESENIUS MEDICAL CARE SUNSHINE DIALYSIS CLINIC',-37.761045,144.815997,'Private'),(304,'ST VINCENTS PRIVATE HOSPITAL WERRIBEE',-37.88776,144.70087,'Private'),(305,'PRECISION ASCEND REHABILITATION CENTRE',-37.86995,145.01785,'Private'),(306,'GENESIS CARE RADIATION ONCOLOGY CENTRE AT CABRINI',-37.862085,145.033342,'Private'),(307,'ROSEBUD ENDOSCOPY',-38.361998,144.889339,'Private'),(308,'ROSEBUD DAY HOSPITAL',-38.361108,144.890647,'Private'),(309,'EPPING PRIVATE HOSPITAL',-37.649368,145.009483,'Private'),(310,'NEW AGE DENTAL',-37.682988,145.073257,'Private'),(311,'GREENSBOROUGH DAY SURGERY',-37.703768,145.106338,'Private'),(312,'DAYHAB',-37.900519,145.144326,'Private'),(313,'ARROW HEALTH',-37.347579,144.536155,'Private'),(314,'VICTORIAN CENTRE FOR MENTAL HEALTH',-38.06024,145.41174,'Private'),(315,'HABITAT THERAPEUTICS',-38.170606,144.399266,'Private'),(316,'THE HADER CLINIC',-38.18054,144.383127,'Private'),(317,'TOORAK COSMETIC SURGERY DAY CENTRE',-37.841312,145.007988,'Private'),(318,'PARAS CLINIC',-37.81422,144.972795,'Private'),(319,'HAMPTON DAY SURGERY',-37.932981,145.032489,'Private'),(320,'ICON CANCER CENTRE MORELAND',-37.754285,144.958516,'Private'),(321,'EPWORTH EASTERN HOSPITAL (2 of 3 campuses)',-37.812587,145.119705,'Private'),(322,'EPWORTH EASTERN HOSPITAL (3 of 3 campuses)',-37.808282,145.048164,'Private'),(323,'THE BAYS HOSPITAL (2 of 2 campuses)',-38.303204,145.190298,'Private'),(324,'GENESISCARE RADIATION ONCOLOGY CENTRE SHEPPARTON',-36.37811,145.403658,'Private'),(325,'ICON CANCER CENTRE GEELONG',-38.193578,144.302721,'Private'),(326,'SOUTH YARRA DAY SURGERY',-37.837278,144.992864,'Private'),(327,'VCI DAY SURGERY',-37.77308,145.109983,'Private'),(328,'GIH ACCESS ENDOSCOPY',-38.059526,145.411655,'Private');

----------------------------------------------------------------------------------------------------------------
-- DEM
WITH dem_data AS (
    SELECT rid, rast
    FROM spatial.victoria_dem_30m_o_2
)
INSERT INTO group_02.victoriadem (RID, Rast)
SELECT rid, rast
FROM dem_data;

----------------------------------------------------------------------------------------------------------------
-- Hotel
WITH filtered_hotels AS (
    SELECT ROW_NUMBER() OVER (ORDER BY name ASC) AS id, name, ST_X(ST_Transform(way, 4326)) as longitude, ST_Y(ST_Transform(way, 4326)) as latitude
    FROM (
        (SELECT name, tags, way
        FROM spatial.melbourne_osm_point
        WHERE (tags?'tourism' AND tags->'tourism' IN ('hotel', 'motel')) AND name IS NOT NULL)) 
        AS hotel_table
)
INSERT INTO group_02.victoriahotel (HotelID, HotelName, Latitude, Longitude)
SELECT id, name, latitude, longitude
FROM filtered_hotels;

----------------------------------------------------------------------------------------------------------------
-- Park
-- Populated through create statement

----------------------------------------------------------------------------------------------------------------
-- Unimelb Campus
WITH cluster_data AS (
    SELECT "OBJECTID" as id, campus, p_cluster, ST_Transform(geom, 4326) as geom
    FROM spatial.unimelb_campus
    )
INSERT INTO group_02.UniMelbCampus (ClusterID, CampusName, CampusCluster, "ClusterLocation")
SELECT id, campus, p_cluster, geom
FROM cluster_data;

--==============================================================================================================
-- DRONE TABLES: User populated
--==============================================================================================================
-- Operator
insert into group_02.operator
values (1, true, 'Employee', interval '0 hour', '123', 'XXX@unimelb'),
(2, true, 'Student', interval '3 hour', '123', 'XXX@unimelb'),
(3, true, 'Employee', interval '51 hour', '123', 'XXX@unimelb'),
(4, false, 'Employee', interval '2 hour', '123', 'XXX@unimelb'),
(5, true, 'Employee', interval '15 hour', '123', 'XXX@unimelb'),
(6, true, 'Employee', interval '1 hour', '123', 'XXX@unimelb'),
(7, true, 'Employee', interval '2 hour', '123', 'XXX@unimelb'),
(8, true, 'Employee', interval '4 hour', '123', 'XXX@unimelb'),
(9, true, 'Employee', interval '5 hour', '123', 'XXX@unimelb');

----------------------------------------------------------------------------------------------------------------
-- Training
insert into group_02.training
values (1, 1, '2023-10-30'),
(2, 1, '2023-10-30'),
(3, 1, '2022-10-30'),
(4, 1, '2021-10-30'),
(5, 1, '2020-10-30'),
(6, 1, '2019-10-30'),
(7, 1, '2018-10-30'),
(8, 1, '2017-10-30'),
(9, 2, '2023-10-30'),
(10, 3, '2023-10-30'),
(11, 4, '2023-10-30'),
(12, 5, '2021-10-30'),
(13, 6, '2023-10-30'),
(14, 6, '2022-10-30'),
(15, 6, '2021-10-30'),
(16, 7, '2023-10-30'),
(17, 8, '2023-10-30'),
(18, 9, '2023-10-30'),
(19, 9, '2022-10-30');

----------------------------------------------------------------------------------------------------------------
-- Battery
insert into group_02.battery
values (1, interval '50 hour', 100, '2023-10-30'),
(2, interval '1 minute', 100, '2023-10-30'),
(3, interval '50 hour', 200, '2023-10-30'),
(4, interval '50 hour', 300, '2023-10-30'),
(5, interval '50 hour', 500, '2023-10-30'),
(6, interval '50 hour', 100, '2020-10-30'),
(7, interval '50 hour', 100, '2019-10-30'),
(8, interval '50 hour', 100, '2018-10-30');

----------------------------------------------------------------------------------------------------------------
-- Sensor
insert into group_02.sensor
values (1, 'Thermal', 150, 100, '2023-10-30'),
(2, 'Infrared', 150, 300, '2023-10-30'),
(3, 'Camera', 150, 100, '2021-10-30'),
(4, 'Thermal', 30, 100, '2023-10-30'),
(5, 'Thermal', 150, 100, '2020-10-30'),
(6, 'Thermal', 150, 100, '2019-10-30'),
(7, 'Thermal', 150, 400, '2023-10-30'),
(8, 'Thermal', 150, 50, '2023-10-30');

----------------------------------------------------------------------------------------------------------------
-- Drone
insert into group_02.drone 
values (1, 1, 1, 30, interval '0 hour', 30, 500),
(2, 1, 1, 30, interval '0 hour', 30, 200),
(3, 1, 1, 100, interval '0 hour', 30, 500),
(4, 1, 8, 30, interval '1 minute', 30, 500),
(5, 6, 1, 30, interval '0 hour', 30, 500),
(6, 1, 2, 30, interval '0 hour', 30, 500),
(7, 4, 1, 30, interval '0 hour', 30, 500);

----------------------------------------------------------------------------------------------------------------
-- Flightpath

-- NOTES:
--   All flight paths are assumed to be closed-loops, hence start and end points are the same
--   Paths below are constructed using 'LINESTRING Z' geometry, consiting of manually inputted Points transformed into 4326 SRID 
--   Paths below all have valid elevations and are all in line-of-sight buffer, making them valid flight paths

insert into group_02.flightpath values 

-- pathid 1: path within unimelb campus
(1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.960585 -37.793903 100, 144.961462 -37.798288 100, 144.95915 -37.79628 100)', 4326), null, null, null, null), 

-- pathid 2: path outside unimelb campus, crosses airport, outside helipad buffers
(2, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.967206 -37.791562 100, 144.936183 -37.769597 100, 144.938544 -37.810602 100, 144.95915 -37.79628 100)', 4326), null, null, null, null),

-- pathid 3: path outside unimelb campus, outside airport and helipad buffers
(3, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.960704 -37.789962 100, 144.963115 -37.801517 100, 144.95915 -37.79628 100)', 4326), null, null, null, null),

-- pathid 4: path at remote location, outside airport and helipad buffers
(4, ST_GeomFromText('LINESTRING Z(144.970320 -37.542600 100, 144.93593 -37.51729 100, 144.94305 -37.56397 100, 144.970320 -37.542600 100)', 4326), null, null, null, null),

-- pathid 5: path outside creswick campus, outside airport and helipad buffers
--           path used to show road path beteen start point and nearest hospital
(5, ST_GeomFromText('LINESTRING Z(143.898699 -37.4233146 100, 143.90492 -37.46292 100, 143.85451 -37.43569 100, 143.898699 -37.4233146 100)', 4326), null, null, null, null);

--==============================================================================================================
-- INSERT STATEMENTS EXPECTED TO FAIL FOR FLIGHTPATH
--==============================================================================================================
insert into group_02.flightpath 

-- 3rd point in flight path has minimum elevation of 10m
values (1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 50, 144.960585 -37.793903 80, 144.961462 -37.798288 10, 144.95915 -37.79628 40)', 4326), null, null, null, null),

-- 3rd point in flight path has maximum elevation of 150m
(1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 50, 144.960585 -37.793903 80, 144.961462 -37.798288 150, 144.95915 -37.79628 40)', 4326), null, null, null, null),

-- flight path in remote location has invalid line-of-sight
(1, ST_GeomFromText('LINESTRING Z(144.970320 -37.542600 100, 144.78085 -37.57402 100, 144.86381 -37.38565 100, 144.970320 -37.542600 100)', 4326), null, null, null, null),

-- fligth path crosses beach area
(1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.942973 -37.847305 100, 144.962700 -37.851058 100, 144.95915 -37.79628 100)', 4326), null, null, null, null),

-- flight path crosses park area
(1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.954187 -37.786260 100, 144.950209 -37.796958 100, 144.95915 -37.79628 100)', 4326), null, null, null, null),

-- flight path crosses helipad buffer
(1, ST_GeomFromText('LINESTRING Z(144.95915 -37.79628 100, 144.9553345 -37.7993786 100, 144.959777 -37.799528 100, 144.95915 -37.79628 100)', 4326), null, null, null, null);

----------------------------------------------------------------------------------------------------------------
-- Flightplan
insert into group_02.flightplan values

 -- flight plan 1 with operator 1 (employee), pathd id 3,  drone 1
 -- outside unimelb, outside airport
(1, '2023-10-30 12:00:00', 1, 3, 1, null, true, null),

 -- flight plan 2 with operator 1 (employee), pathd id 3,  drone 3
 -- outside unimelb, outside of airport
(2, '2023-10-29 12:00:00', 1, 3, 3, null, true, null), 

 -- flight plan 3 with operator 2 (student), pathd id 1,  drone 1
 -- inside unimelb, outside airport
(3, '2023-10-28 12:00:00', 2, 1, 1, null, true, null), 

 -- flight plan 4 with operator 4 (employee unlicensed), pathd id 3,  drone 1
 -- outside parunimelb, outside airport
(4, '2023-10-27 12:00:00', 4, 3, 1, null, false, null),

 -- flight plan 5 with operator 1 (employee), pathd id 5,  drone 1
 -- outside creswick, outside airport
(5, '2023-10-31 12:00:00', 1, 5, 1, null, true, null); 

--==============================================================================================================
-- INSERT STATEMENTS EXPECTED TO FAIL FOR FLIGHTPLAN
--==============================================================================================================
insert into group_02.flightplan
-- Path = inside unimelb, outside airport
values (1, '2023-10-30 12:00:00', 1, 1, 2, null, true, null), -- drone exceeds payload
(1, '2023-10-30 12:00:00', 1, 1, 4, null, true, null), -- battery hasn't been inspected recently
(1, '2023-10-30 12:00:00', 1, 1, 5, null, true, null), -- sensor hasn't been calibrated recently
(1, '2023-10-30 12:00:00', 1, 1, 6, null, true, null), -- battery nearly flat
(1, '2023-10-30 12:00:00', 1, 1, 7, null, true, null), -- flies above sensor max altitude
(1, '2023-10-30 12:00:00', 3, 1, 1, null, true, null), -- operator has exceeded 50 flight hours without refresher course
(1, '2023-10-30 12:00:00', 4, 1, 1, null, true, null), -- no licence to fly commercial flight
(1, '2023-10-30 12:00:00', 5, 1, 1, null, true, null), -- operator has not taken refresher course in more than a year

-- Path 2 outside unimelb, inside airport
(1, '2023-10-30 12:00:00', 1, 2, 3, null, true, null), -- weight exceeds 250g and within airport
-- Path 3 outside unimelb, outside airport
(1, '2023-10-30 12:00:00', 2, 3, 1, null, true, null); -- student can't fly outside unimelb
