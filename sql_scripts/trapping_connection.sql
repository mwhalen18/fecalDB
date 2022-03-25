-- !preview conn=DBI::dbConnect(RMySQL::MySQL(), group = "krsp-aws")

SELECT id as trapping_id, 
  gr as grid, 
  squirrel_id, 
  date, 
  comments, 
  tvariable1, 
  tagLft as tag_l, 
  tvariable2,
  tagRt as tag_r
FROM trapping
WHERE squirrel_id is not null
;
