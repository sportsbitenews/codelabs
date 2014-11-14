# Private variants within BRCA1
SELECT
  reference_name AS CHROM,
  start AS POS,
  CASE WHEN cnt = 1 THEN 'S'
  WHEN cnt = 2 THEN 'D'
  ELSE STRING(cnt) END AS SINGLETON_DOUBLETON,
  reference_bases AS REF,
  alternate_bases AS ALLELE,
  call.call_set_name AS INDV,
  alt_num,
  genotype,
  cnt
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    alternate_bases,
    alt_num,
    call.call_set_name,
    GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
    SUM(call.genotype == alt_num) WITHIN call AS cnt,
    COUNT(call.call_set_name) WITHIN RECORD AS num_samples_with_variant
  FROM (
      FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          POSITION(alternate_bases) AS alt_num,
          call.call_set_name,
          call.genotype,
        FROM
          [_THE_TABLE_]
        WHERE
          reference_name = 'chr17'
          AND start BETWEEN 41196311
          AND 41277499
          ),
        alternate_bases)
      )
  OMIT
    RECORD IF alternate_bases IS NULL
  HAVING
    num_samples_with_variant = 1
    AND cnt > 0
    )
ORDER BY
  POS, INDV
