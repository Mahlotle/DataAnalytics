#FIRST PROJECT
#--------------DATA CLEANING. 


SELECT * 
FROM world_layoffs.layoffs;

#--1. REMOVE DUPLICATES
#--2. STANDARDIZE THE DATA (fixing spellings and other issues)
#--3. NULL VALUES OR BLANK SPACE/VALUE (see if we can populate or not )
#--4. Remove any colomns


#copying an existing table and creating its twin to work with (
#cant work on raw data just incase you mess it up you will always have the original

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


#--1. REMOVE DUPLICATES
SELECT * ,
ROW_NUMBER()
OVER( PARTITION BY company, industry,total_laid_off, percentage_laid_off, `date`) AS  raw_num
FROM layoffs_staging;


#step1:creating a commont table expression to identify duplicates
WITH duplicates_cte AS
(
	SELECT * ,
	ROW_NUMBER()
	OVER( PARTITION BY company,location, industry,total_laid_off, percentage_laid_off, `date`,
    stage,country,funds_raised_millions
    ) AS  raw_num
	FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE raw_num>1
;

#step2: delete dupliates
#leftclick_layoff_staging>>copy click board>> create statement>>then paste

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `raw_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
	SELECT * ,
	ROW_NUMBER()
	OVER( PARTITION BY company,location, industry,total_laid_off, percentage_laid_off, `date`,
    stage,country,funds_raised_millions
    ) AS  raw_num
	FROM layoffs_staging;


SELECT*
FROM layoffs_staging2
WHERE raw_num>1
;

DELETE
FROM layoffs_staging2
WHERE raw_num>1
;

#-----------------2. STANDARDIZE THE DATA (fixing spellings and other issues)

#step1: remove white spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

#step2: DISTINCT

SELECT DISTINCT industry
FROM layoffs_staging2
;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) #trailing means coming at the end
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

#changing date datatype from String TO Date
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN  `date` DATE;

select * from layoffs_staging2;


#step 3: Fixing blank spaces and nulls
#--3. NULL VALUES OR BLANK SPACE/VALUE (see if we can populate or not )


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
;

SELECT * 
FROM layoffs_staging2
WHERE industry = '';


#Populating Industry based on common company

#iddentifying identical componies where one enetry might be blank or null on industry
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
		ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

#setting BLANK to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

select industry, company
from layoffs_staging2
where company='Airbnb';

#----4. Remove any colomns
#DLETING RAWS WHERE THE TOTAL LAYED OFF AND PERCENTAGE LAID OFF IS NULL

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL
;
SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL
;


#DROPPING A COLOUM IN A TABLE

ALTER TABLE layoffs_staging2
DROP COLUMN raw_num
;

