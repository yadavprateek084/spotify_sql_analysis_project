-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


delete from spotify
where duration_min = 0

select * from spotify

-- Easy Level
-- 1.Retrieve the names of all tracks that have more than 1 billion streams.

select distinct track from spotify where stream > 1000000000

-- 2.List all albums along with their respective artists.

select album,artist from spotify 

-- 3.Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) from spotify where licensed = 'TRUE'

-- 4.Find all tracks that belong to the album type single.

select track from spotify where album_type = 'single'
 
-- 5.Count the total number of tracks by each artist.

select artist, count(*) as counter from spotify group by artist order by counter desc

-- Medium Level

-- 6.Calculate the average danceability of tracks in each album.

select 
	album,
	round(avg(danceability)::numeric,3) as avg_danceability
from spotify
group by 1
order by 2 desc

-- 7.Find the top 5 tracks with the highest energy values.

select *
from spotify
order by energy desc
limit 5

-- 8.List all tracks along with their views and likes where official_video = TRUE.

select 
	track,
	sum(views) as total_views,
	sum(likes) as total_likes
from spotify 
where official_video = 'TRUE'
group by 1

-- 9.For each album, calculate the total views of all associated tracks.
with cte as 
(select album,track,sum(views) as total_views
from spotify
group by 1,2
)
select 
album,track,total_views,sum(total_views)over(partition by album) as composite_view 
from cte
order by composite_view desc

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

select distinct track
from spotify
where most_played_on = 'Spotify' and most_played_on = 'Youtube'

-- Advanced Level

-- 11.Find the top 3 most-viewed tracks for each artist using window functions.

explain analyze

with cte as
(
select
	artist,
	track,
	sum(views) as sum_of_view,
	row_number()over(partition by artist order by sum(views) desc) as ranks
from spotify
group by 1,2
)

select *
from cte
where ranks<=3

-- 12.Write a query to find tracks where the liveness score is above the average.

select distinct track,liveness 
from spotify
where liveness > ( select round(avg(liveness)::numeric,2) from spotify )

-- 13.Use a WITH clause to calculate the difference between
--the highest and lowest energy values for tracks in each album.
---

select 
	distinct album,
	max(round(energy_liveness::numeric,2))over(partition by album) as maximum_energy, 
	min(round(energy_liveness::numeric,2))over(partition by album) as min_energy,
	round(avg(energy_liveness::numeric)over(partition by album),2) as avg_energy
from spotify
order by round(avg(energy_liveness::numeric)over(partition by album),2) desc


--14.Find tracks where the energy-to-liveness ratio is greater than 1.2.

with cte as
(select track,(round(100*(energy_liveness::numeric/liveness))) as energy_liveness_ratio
from spotify )

select * 
from cte
where energy_liveness_ratio>1.2

--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select track,sum(likes) as total_likes 
from spotify
group by 1
order by sum(views) desc


---query optimization
explain analyze -- et 6.15 pt 0.16
select 
artist,track,views
from spotify 
where artist = 'Gorillaz'
	and
	most_played_on = 'Youtube'
order by stream desc limit 250


create index artist_index on spotify(artist)
