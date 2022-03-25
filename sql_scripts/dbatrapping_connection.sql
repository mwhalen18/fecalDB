-- !preview conn=DBI::dbConnect(RMySQL::MySQL(), group = "krsp-aws")

SELECT id as trapping_id,
  squirrel_id,
  date,
  TagHist as comments, 
  poop, 
  ptime, 
  tagLft as tag_l,
  tagRt as tag_r
FROM dbatrapping
where poop <> "";
