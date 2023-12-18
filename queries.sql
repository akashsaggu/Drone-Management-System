----------------------------------------------------------------------------------------------------------------
-- QUERIES
----------------------------------------------------------------------------------------------------------------
-- Query 1: The following query returns the 3 nearest hotels to the starting point of a flight path

-- Flight path used is flightid 4, having a starting point at a remote location in victoria
-- Query returns 3 names and geometries of the nearest hotels to the path's starting point

SELECT hotel.hotelname, hotel.geom
FROM group_02.victoriahotel as hotel, group_02.flightpath AS path
WHERE path.pathid = 4 -- Fill pathid here
ORDER BY ST_GeomFromText(path.startpoint, 4326) <-> ST_Transform(hotel.geom, 4326)
LIMIT 3;

----------------------------------------------------------------------------------------------------------------
-- Query 2: The following query returns the road path between the 
--          flight path's starting point and the nearest hospital to that point

-- Flight path used is flightid 5, having a starting point at the Creswick University of Melbourne campus
-- Query returns geometries of the road path between these points

-- Finds id of closest vertex point from VicRoads vertices to closest hospital's Point from path start point
WITH end_point AS (
	SELECT p.id, nearestHospital.hospitalname
	FROM (
    	SELECT hospital.hospitalname AS hospitalname, hospital.geom AS geom
		FROM group_02.victoriahospital as hospital, group_02.flightpath AS path
		WHERE path.pathid = 5 -- fill pathid here
		ORDER BY ST_Transform(path.startPoint, 4326) <-> ST_Transform(hospital.geom, 4326)
		LIMIT 1
		) AS nearestHospital, spatial.victoria_roads2023_vertices_pgr AS p
	ORDER BY ST_transform(nearestHospital.geom, 4326) <-> ST_Transform(p.the_geom, 4326)
	LIMIT 1
),

-- Finds id of closest vertex point from VicRoads vertices to flight path's start point
start_point AS (
    SELECT p.id, path.startpoint AS startpoint
    FROM group_02.flightpath as path, spatial.victoria_roads2023_vertices_pgr AS p
	WHERE path.pathid = 5 -- fill pathid here
	ORDER BY ST_Transform(path.startpoint, 4326) <-> ST_Transform(p.the_geom, 4326)    
	LIMIT 1
),

-- Retrieves shortest road path to hospital from flight path start point
shortest_path AS (
    SELECT seq, node, edge
    FROM pgr_dijkstra( 'SELECT "OBJECTID" AS id, source, target, ST_Length(ST_Transform(ST_Transform(geom, 4326), 7855)) AS cost 
                        FROM spatial.victoria_roads2023',
                    (SELECT id FROM start_point), 
                    (SELECT id FROM end_point), 
                    false
    )
)

-- Uses VicRoads to get the road path, along with its sequence of Geometry Points
SELECT    
    ST_Transform(vicroad.geom, 4326) as geom
FROM 
    shortest_path Spath
JOIN 
    spatial.victoria_roads2023 vicroad
ON 
    Spath.edge = vicroad."OBJECTID"
ORDER BY 
    Spath.seq;
	
----------------------------------------------------------------------------------------------------------------
