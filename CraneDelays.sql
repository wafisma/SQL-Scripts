--CraneDeays
Declare @DateFrom varchar(11);
SET @DateFrom = '01-01-2022'--CONVERT(date, $P{From Date(DD-MM-YYYY)} ,105);--'01-01-2022'
Declare @DateTo varchar(11);
SET @DateTo =  '01-10-2022'--Convert(date, $P{To Date(DD-MM-YYYY)} ,105);--'12-01-2022'
SELECT xche.short_name as 'Crane',ref.description as 'Description',--vca.start_time,vca.end_time,
'Sum Delays'= sum((DATEDIFF(second,vca.start_time,vca.end_time) ) /60.0)
FROM [sparcsn4].[dbo].[vsl_crane_activity] vca
INNER JOIN [xps_che] xche ON xche.[gkey]=vca.crane_gkey
INNER JOIN [ref_crane_delay_types] ref ON ref.gkey=vca.crane_delay_type_gkey
WHERE (vca.start_time >= @DateFrom)  AND (vca.start_time <= @DateTo) --AND DATEDIFF(DAY,vca.start_time,vca.end_time)BETWEEN 0 AND 30
--and (case when  DATEDIFF(DAY,vca.start_time,vca.end_time)<=30 then  else NULL end)<=30
--AND vca.start_time>dateadd(month,-6, GETDATE())
group by 
xche.short_name ,ref.description 
--having (case when (vca.start_time >= @DateFrom)  AND (vca.start_time <= @DateTo) then DATEDIFF(DAY,vca.start_time,vca.end_time) else NULL end)<=30
order by 1,2