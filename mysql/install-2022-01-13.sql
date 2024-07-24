/*
install.sql
*/

# Initialize
  SET @THIS_SCRIPT="install_configs.sql";
  SET @TIME_START=NOW();
  USE `liturgy`;
  INSERT INTO `-log`
    SET timezone=@@system_time_zone, description=concat(@THIS_SCRIPT," executed");
# Define Functions
  # F_-EXAMPLE
    /*
    Don't try to use a variable function name so it can be replicated below.
    Already thought of that, and it doesn't work.
    See https://stackoverflow.com/questions/8809943/how-to-select-from-mysql-where-table-name-is-variable
    Don't do it.
    Learn more: https://dev.mysql.com/doc/refman/8.0/en/create-procedure.html
    */
    DROP FUNCTION IF EXISTS `F_-EXAMPLE`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_-EXAMPLE`
      (`iVariable1` INT, `iVariable2` varchar(255))
      RETURNS INT
      # DETERIINISTIC or NOT DETERMINISTIC
      # https://stackoverflow.com/questions/7946553/deterministic-function-in-mysql
      DETERMINISTIC
      COMMENT 'This is a comment.'
      BEGIN
        /*
        Statements. Must include a RETURN.
        Don't forget semicolons at the end of a commmand.
        Note two semicolons after END **ONLY**
        */
        IF true /* Note parentheses for return argument optional */
          THEN RETURN true; /* Note semicolon and parentheses for return argument optional */
          ELSE RETURN false;
          END IF; /* Note semicolon after END IF */
        RETURN NULL;
      END ;;
    DELIMITER ;
  # date_all_saints
    DROP FUNCTION IF EXISTS `date_all_saints`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `date_all_saints`
      (iDateTime DATETIME) RETURNS date
      DETERMINISTIC
      BEGIN
        RETURN (MAKEDATE(YEAR(iDateTime),
          DAYOFYEAR(CONCAT(YEAR(iDateTime),'-11-01'))));
      END ;;
    DELIMITER ;
  # date_july_1
    DROP FUNCTION IF EXISTS `date_july_1`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `date_july_1`(iDateTime DATETIME) RETURNS date
    DETERMINISTIC
      BEGIN
        RETURN (MAKEDATE(YEAR(iDateTime),
          DAYOFYEAR(CONCAT(YEAR(iDateTime),'-07-01'))));
      END ;;
    DELIMITER ;
  # date_labor_day
    DROP FUNCTION IF EXISTS `date_labor_day`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `date_labor_day`(iDateTime DATETIME) RETURNS date
    DETERMINISTIC
      BEGIN
          RETURN MAKEDATE(YEAR(iDateTime),DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07'))
       - WEEKDAY(MAKEDATE(YEAR(iDateTime),DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07')))));
      END ;;
    DELIMITER ;
  # date_of_1_advent
    DROP FUNCTION IF EXISTS `date_of_1_advent`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `date_of_1_advent`(iYear INT) RETURNS date
      DETERMINISTIC
      BEGIN
      RETURN STR_TO_DATE(CONCAT(iYear,'-12-04'),'%Y-%m-%d')
        - INTERVAL DAYOFWEEK(CONCAT(iYear,'-12-24')) DAY;
      END ;;
    DELIMITER ;
  # date_of_1_epiphany
    DROP FUNCTION IF EXISTS `date_of_1_epiphany`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `date_of_1_epiphany`
    (iYear INT)
    RETURNS date
    DETERMINISTIC
    BEGIN
      RETURN STR_TO_DATE(CONCAT(iYear,'-01-14'),'%Y-%m-%d')
        - INTERVAL DAYOFWEEK(CONCAT(iYear,'-01-13')) DAY;
    END ;;
    DELIMITER ;
  # date_of_easter
    DROP FUNCTION IF EXISTS `date_of_easter`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `date_of_easter`(iYear INT)
    RETURNS date
    DETERMINISTIC
      BEGIN
      SET @iD=0,@iE=0,@iQ=0,@iMonth=0,@iDay=0;
      SET @iD = 255 - 11 * (iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (iYear + FLOOR(iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
      SET @iMonth = 3;
      SET @iDay = @iQ;
      ELSE
      SET @iMonth = 4;
      SET @iDay = @iQ - 31;
      END IF;
      RETURN STR_TO_DATE(CONCAT(iYear,'-',@iMonth,'-',@iDay),'%Y-%m-%d');
      END ;;
    DELIMITER ;
  # easter_offset
    DROP FUNCTION IF EXISTS `easter_offset`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `easter_offset`(iDate DATE)
    RETURNS int
      DETERMINISTIC
      BEGIN
      RETURN DATEDIFF(iDate,date_of_easter(YEAR(iDate)));
      END ;;
    DELIMITER ;
  # easter_ofset_days
    DROP FUNCTION IF EXISTS `easter_offset_days`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `easter_offset_days`(iDate DATE) RETURNS int
    DETERMINISTIC
      BEGIN
        RETURN DATEDIFF(iDate,date_of_easter(YEAR(iDate)));
      END ;;
    DELIMITER ;
  # easter_offset_sundays
    DROP FUNCTION IF EXISTS `easter_offset_sundays`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `easter_offset_sundays`(iDate DATE) RETURNS int
      DETERMINISTIC
      BEGIN
        RETURN DATEDIFF(week_of(iDate),date_of_easter(YEAR(iDate)))/7;
      END ;;
    DELIMITER ;
  # eucharistic_prayer
    DROP FUNCTION IF EXISTS `eucharistic_prayer`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `eucharistic_prayer`(iEucharisticPrayer INT, iDateTime DATETIME, iSeason VARCHAR(30), iObservance VARCHAR(40),
      iEve INT, iRite VARCHAR(2), iLocation VARCHAR(12), iFuneral INT, iMarriage INT,
      iBlessingRelationship INT)
      RETURNS int
        DETERMINISTIC
      BEGIN
      IF (iEucharisticPrayer) THEN
        RETURN(iEucharisticPrayer);
        ELSE IF iRite='1' THEN
          RETURN(899);
          ELSE IF (iLocation='Chapel' AND HOUR(iDateTime)=10 AND WEEKDAY(iDateTime)=2)
              OR (WEEKDAY(iDateTime)=5 AND HOUR(iDateTime)=17) THEN
            RETURN(900);
            ELSE IF iSeason='Advent' THEN
              RETURN(908);
              ELSE IF (LEFT(iObservance,9)='Christmas' AND HOUR(iDateTime)>20)
                  OR iObservance='Easter Vigil' OR iObservance='EasterDay' THEN
                RETURN(903);
                ELSE IF iSeason='Christmastide' OR iSeason='Eastertide' OR iObservance='Trinity Sunday'
                    OR iMarriage OR iBlessingRelationship OR iFuneral THEN
                  RETURN(901);
                  ELSE IF iSeason='Epiphanytide'
                      OR iSeason='Season after Pentecost' AND MONTH(iDateTime)>=11 THEN
                    RETURN (907);
                    ELSE IF MONTH(iDateTime)>=7
                        AND iDateTime < DATE_SUB(MAKEDATE(YEAR(iDateTime),
                          DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07'))),INTERVAL
                          WEEKDAY(MAKEDATE(YEAR(iDateTime),DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07')))) DAY) THEN
                      RETURN(902);
                      ELSE IF iDateTime >= DATE_SUB(MAKEDATE(YEAR(iDateTime),
                          DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07'))),INTERVAL
                          WEEKDAY(MAKEDATE(YEAR(iDateTime),DAYOFYEAR(CONCAT(YEAR(iDateTime),'-09-07')))) DAY)
                            AND MONTH(iDateTime)<11 THEN
                        RETURN(906);
                        ELSE RETURN(900);
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END ;;
    DELIMITER ;
  # F2DateOfEaster
    DROP FUNCTION IF EXISTS `F2DateOfEaster`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F2DateOfEaster`(iYear INT) RETURNS date
      DETERMINISTIC
      BEGIN
      SET @iD=0,@iE=0,@iQ=0,@iMonth=0,@iDay=0;
      SET @iD = 255 - 11 * (iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (iYear + FLOOR(iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
      SET @iMonth = 3;
      SET @iDay = @iQ;
      ELSE
      SET @iMonth = 4;
      SET @iDay = @iQ - 31;
      END IF;
      RETURN STR_TO_DATE(CONCAT(iYear,'-',@iMonth,'-',@iDay),'%Y-%m-%d');
      END ;;
    DELIMITER ;
  # F2Observance
    DROP FUNCTION IF EXISTS `F2Observance`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `F2Observance`(iDate DATE)
    RETURNS varchar(64)
    DETERMINISTIC
      BEGIN
        SET @WeekdaySunday = 6;
        IF WEEKDAY(iDate) = @WeekdaySunday THEN
          SET @DayOfYear=DAYOFYEAR(iDate);
          IF @DayOfYear<6 THEN RETURN("2 Christmas"); END IF;
          IF @DayOfYear=6 THEN RETURN("Epiphany"); END IF;
          SET @Result=CONCAT(FLOOR(@DayOfYear/7)," Epiphany");
          SET @NextResult=CASE
            FLOOR(@DayOfYear-(DAYOFYEAR(F2DateOfEaster(YEAR(iDate)))-56))/7
              WHEN 1 THEN "Last Epiphany"
              WHEN 2 THEN "1 Lent"
              WHEN 3 THEN "2 Lent"
              WHEN 4 THEN "3 Lent"
              WHEN 5 THEN "4 Lent"
              WHEN 6 THEN "5 Lent"
              WHEN 7 THEN "Palm Sunday"
              WHEN 8 THEN "Easter Day"
              WHEN 9 THEN "2 Easter"
              WHEN 10 THEN "3 Easter"
              WHEN 11 THEN "4 Easter"
              WHEN 12 THEN "5 Easter"
              WHEN 13 THEN "6 Easter"
              WHEN 14 THEN "7 Easter"
              WHEN 15 THEN "Pentecost Day"
              WHEN 16 THEN "Trinity Sunday"
              WHEN 17 THEN "2 Pentecost"
              WHEN 18 THEN "3 Pentecost"
              WHEN 19 THEN "4 Pentecost"
              WHEN 20 THEN "5 Pentecost"
              WHEN 21 THEN "6 Pentecost"
              WHEN 22 THEN "7 Pentecost"
              WHEN 23 THEN "8 Pentecost"
              WHEN 24 THEN "9 Pentecost"
              WHEN 25 THEN "10 Pentecost"
              WHEN 26 THEN "11 Pentecost"
              WHEN 27 THEN "12 Pentecost"
              WHEN 28 THEN "13 Pentecost"
              WHEN 29 THEN "14 Pentecost"
              WHEN 30 THEN "15 Pentecost"
              WHEN 31 THEN "16 Pentecost"
              WHEN 32 THEN "17 Pentecost"
              WHEN 33 THEN "18 Pentecost"
              WHEN 34 THEN "19 Pentecost"
              WHEN 35 THEN "20 Pentecost"
              WHEN 36 THEN "21 Pentecost"
              WHEN 37 THEN "22 Pentecost"
              WHEN 38 THEN "23 Pentecost"
              WHEN 39 THEN "24 Pentecost"
              WHEN 40 THEN "25 Pentecost"
              WHEN 41 THEN "26 Pentecost"
              WHEN 42 THEN "27 Pentecost"
          END;
          SET @Result=IF(ISNULL(@NextResult),@Result,@NextResult);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>19,"Christ the King",@Result);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>26,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>3,"2 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>10,"3 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>17,"4 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)=25,"Christmas",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>25,"1 Christmas",@Result);
          RETURN(@Result);
        ELSE
          RETURN("Non-Sunday");
        END IF;
      END ;;
    DELIMITER ;
  # F2ObservanceDefault
    DROP FUNCTION IF EXISTS `F2ObservanceDefault`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F2ObservanceDefault`(iDate DATE)
        RETURNS varchar(64)
      DETERMINISTIC
      BEGIN
        SET @WeekdayMonday = 0;
        SET @WeekdayTuesday = 1;
        SET @WeekdaySunday = 6;
        SET @DayOfYear=DAYOFYEAR(iDate);
        IF WEEKDAY(iDate) = @WeekdaySunday THEN
          IF @DayOfYear=1 THEN RETURN("Holy Name"); END IF;
          IF @DayOfYear=6 THEN RETURN("Epiphany"); END IF;
          IF (MONTH(iDate)=2 AND DAY(iDate)=2) THEN RETURN("Presentation"); END IF;
          IF (MONTH(iDate)=8 AND DAY(iDate)=6) THEN RETURN("Transfiguration"); END IF;
          IF (MONTH(iDate)=25 AND DAY(iDate)=25) THEN RETURN("Christmas"); END IF;
          IF @DayOfYear<6 THEN RETURN("2 Christmas"); END IF;
          SET @Result=CONCAT(FLOOR(@DayOfYear/7)," Epiphany");
          SET @NextResult=CASE
            FLOOR(@DayOfYear-(DAYOFYEAR(F2DateOfEaster(YEAR(iDate)))-56))/7
              WHEN 1 THEN "Last Epiphany"
              WHEN 2 THEN "1 Lent"
              WHEN 3 THEN "2 Lent"
              WHEN 4 THEN "3 Lent"
              WHEN 5 THEN "4 Lent"
              WHEN 6 THEN "5 Lent"
              WHEN 7 THEN "Palm Sunday"
              WHEN 8 THEN "Easter Day"
              WHEN 9 THEN "2 Easter"
              WHEN 10 THEN "3 Easter"
              WHEN 11 THEN "4 Easter"
              WHEN 12 THEN "5 Easter"
              WHEN 13 THEN "6 Easter"
              WHEN 14 THEN "7 Easter"
              WHEN 15 THEN "Pentecost Day"
              WHEN 16 THEN "Trinity Sunday"
              WHEN 17 THEN "2 Pentecost"
              WHEN 18 THEN "3 Pentecost"
              WHEN 19 THEN "4 Pentecost"
              WHEN 20 THEN "5 Pentecost"
              WHEN 21 THEN "6 Pentecost"
              WHEN 22 THEN "7 Pentecost"
              WHEN 23 THEN "8 Pentecost"
              WHEN 24 THEN "9 Pentecost"
              WHEN 25 THEN "10 Pentecost"
              WHEN 26 THEN "11 Pentecost"
              WHEN 27 THEN "12 Pentecost"
              WHEN 28 THEN "13 Pentecost"
              WHEN 29 THEN "14 Pentecost"
              WHEN 30 THEN "15 Pentecost"
              WHEN 31 THEN "16 Pentecost"
              WHEN 32 THEN "17 Pentecost"
              WHEN 33 THEN "18 Pentecost"
              WHEN 34 THEN "19 Pentecost"
              WHEN 35 THEN "20 Pentecost"
              WHEN 36 THEN "21 Pentecost"
              WHEN 37 THEN "22 Pentecost"
              WHEN 38 THEN "23 Pentecost"
              WHEN 39 THEN "24 Pentecost"
              WHEN 40 THEN "25 Pentecost"
              WHEN 41 THEN "26 Pentecost"
              WHEN 42 THEN "27 Pentecost"
              END;
          SET @Result=IF(ISNULL(@NextResult),@Result,@NextResult);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>19,"Christ the King",@Result);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>26,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>3,"2 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>10,"3 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>17,"4 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>25,"1 Christmas",@Result);
          RETURN(@Result);
        ELSE
          IF (@DayOfYear=(DAYOFYEAR(F2DateOfEaster(YEAR(iDate)))-46))
            THEN SET @Result=("Ash Wednesday");
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 6 DAY)))
            THEN SET @Result="Holy Monday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 5 DAY)))
            THEN SET @Result="Holy Tuesday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 4 DAY)))
            THEN SET @Result="Holy Wednesday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 3 DAY)))
            THEN SET @Result="Maundy Thursday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 2 DAY)))
            THEN SET @Result="Good Friday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 1 DAY)))
            THEN SET @Result="Holy Saturday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 1 DAY)))
            THEN SET @Result="Easter Monday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 2 DAY)))
            THEN SET @Result="Easter Tuesday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 3 DAY)))
            THEN SET @Result="Easter Wednesday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 4 DAY)))
            THEN SET @Result="Easter Thursday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 5 DAY)))
            THEN SET @Result="Easter Friday";
            END IF;
          IF (iDate=(DATE_SUB(F2DateOfEaster(YEAR(iDate)),INTERVAL 6 DAY)))
            THEN SET @Result="Easter Saturday";
            END IF;
          IF (iDate=(DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 39 DAY)))
            THEN SET @Result="Ascension";
            END IF;
          IF (MONTH(iDate)=1 AND DAY(iDate)=1)
            THEN SET @Result=("Holy Name");
            END IF;
          IF (MONTH(iDate)=1 AND DAY(iDate)=6)
            THEN SET @Result=("Epiphany");
            END IF;
          IF (MONTH(iDate)=2 AND DAY(iDate)=2)
            THEN SET @Result=("Presentation");
            END IF;
          IF (MONTH(iDate)=8 AND DAY(iDate)=6)
            THEN SET @Result=("Transfiguration");
            END IF;
          IF (MONTH(iDate)=11 AND DAY(iDate)=1)
            THEN SET @Result=("All Saints' Day");
            END IF;
          IF (MONTH(iDate)=12 AND DAY(iDate)=25)
            THEN SET @Result=("Christmas");
            END IF;
          IF iDate=DATE_ADD(F2DateOfEaster(YEAR(iDate)),INTERVAL 9 DAY) THEN
            RETURN("TUE FLAG");
            END IF;
          IF ISNULL(@Result) THEN
            SET @Result=CASE WEEKDAY(iDate)
              WHEN @WeekdayMonday THEN "Monday"
              WHEN @WeekdayTuesday THEN "Tuesday"
              WHEN 2 THEN "Wednesday"
              WHEN 3 THEN "Thursday"
              WHEN 4 THEN "Friday"
              WHEN 5 THEN "Saturday"
            END;
          END IF;
          RETURN(@Result);
        END IF;
      END ;;
    DELIMITER ;
  # F_blanknull
    DROP FUNCTION IF EXISTS `F_blanknull`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_blanknull`(`i_text` varchar(255)) RETURNS varchar(255)
      DETERMINISTIC
      BEGIN
        IF (F_max_track_id(i_proper_id,i_lectionary_year_id))
          THEN RETURN (F_track_id(i_proper_id,i_lectionary_year_id));
          ELSE RETURN(0);
          END IF;
      END ;;
    DELIMITER ;
  # F_boolean
    DROP FUNCTION IF EXISTS `F_boolean`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_boolean`(`inval` VARCHAR(7)) RETURNS int
      READS SQL DATA
      DETERMINISTIC
    BEGIN
      IF ((left(inval,1)="y")
        OR (left(inval,2)="on")
        OR (left(inval,1)="t")
        OR (left(inval,1)="1")
        OR (left(inval,1)="-"))
      THEN
        RETURN(1);
      ELSE
        RETURN(0);
      END IF;
    END ;;
    DELIMITER ;
  # F_california_text_type
    DROP FUNCTION IF EXISTS `F_california_text_type`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_california_text_type`
    (`i_citation_id` INT, i_default_text_type_id INT )
    RETURNS int
      DETERMINISTIC
      COMMENT 'Returns 520 if California text found, else i_default_text_type_id.'
      BEGIN
        IF (SELECT DISTINCT t.text_id
          FROM texts t
          WHERE t.text_type_id=520 AND t.citation_id=i_citation_id)
            THEN RETURN(520);
            ELSE RETURN(i_default_text_type_id);
            END IF;
      END ;;
    DELIMITER ;
  # F_citation_id
    DROP FUNCTION IF EXISTS `F_citation_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_citation_id`(`i_obs_date` DATE, `i_proper_id` INT, `i_lectionary_year_id` INT,
        `i_citation_usage` INT, `i_alt_rite` INT) RETURNS int
        DETERMINISTIC
        RETURN(
            SELECT m.citation_id FROM(
              SELECT DISTINCT
                F_override_filters_1_and_2(l.proper_id,l.lectionary_year_id,
                  l.lectionary_track_id,l.citation_usage_id,l.rite_id,l.citation_id)
                  citation_id,
                F_citation_length(F_override_filters_1_and_2(l.proper_id,
                  l.lectionary_year_id,l.lectionary_track_id,l.citation_usage_id,
                  l.rite_id,l.citation_id)) citation_length
              FROM lectionary_contents l
              WHERE l.lectionary_id=F_config_int("lectionary_id")
                AND l.proper_id=i_proper_id
                AND l.lectionary_year_id=i_lectionary_year_id
                AND (l.lectionary_track_id
                  =F_this_track_id(i_proper_id,i_lectionary_year_id)
                  OR l.lectionary_track_id=0)
                AND l.citation_usage_id=i_citation_usage
                AND (F_config_boolean("use_lane_shortened_citations")
                  OR NOT(l.lane_extension))
                AND if(i_alt_rite,
                  l.rite_id=if(F_config_int("rite_id")=1,2,
                    if(F_config_int("rite_id")=2,1,0)),
                      (l.rite_id=0 OR l.rite_id=F_config_int("rite_id")))
                AND cast(cast(l.citation_option_index AS CHAR) AS UNSIGNED INTEGER)
                  =MOD(YEAR(i_obs_date),F_max_citation_option_index(i_proper_id,
                    i_lectionary_year_id,i_citation_usage,i_alt_rite)+1)
              ) m
            WHERE m.citation_length=F_target_citation_length(i_obs_date,
              i_proper_id,i_lectionary_year_id,
              i_citation_usage,i_alt_rite)
            ) ;;
    DELIMITER ;
  # F_citation_length
    DROP FUNCTION IF EXISTS `F_citation_length`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `F_citation_length`(`i_citation_id` INT)
    RETURNS int
    DETERMINISTIC
    BEGIN
      RETURN(SELECT
        LENGTH(t.text_content)
        FROM texts t
        WHERE t.text_id=F_text_id(i_citation_id));
    END ;;
    DELIMITER ;
  # F_citation_track_id
    DROP FUNCTION IF EXISTS `F_citation_track_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_citation_track_id`
      (`i_proper_id` INT, `i_lectionary_year_id` INT, `i_track_id` INT)
      RETURNS int
      DETERMINISTIC
      BEGIN
        RETURN(
              IF ((
                  SELECT
                    o.lectionary_track_id_out
                  FROM `_configuration` o
                  WHERE o.override_type_id=3
                    # AND o.config_set_id=F_config_active_set()
                    AND o.lectionary_id_in=F_config_int("lectionary_id")
                    AND o.proper_id_in=i_proper_id
                    AND o.lectionary_year_id_in=i_lectionary_year_id
                  ) IS NULL,
                    if(i_track_id,F_config_int("track_id"),i_track_id), (
                      SELECT
                        o.lectionary_track_id_out
                      FROM `_configuration` o
                      WHERE F_config_boolean("apply_overrides")
                        # AND o.config_set_id=F_config_active_set()
                        AND o.override_type_id=3
                        AND o.lectionary_id_in=F_config_int("lectionary_id")
                        AND o.proper_id_in=i_proper_id
                        AND o.lectionary_year_id_in=i_lectionary_year_id
                      ))
                ) ;
      END ;;
    DELIMITER ;
  # F_config_active_set
    DROP FUNCTION IF EXISTS `F_config_active_set`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_active_set`()
      RETURNS int
      READS SQL DATA
      DETERMINISTIC
      COMMENT 'Returns current active_set from table `configuration`'
      BEGIN
        RETURN(
          SELECT config_value FROM configuration
            WHERE NOT(CAST(group_id AS UNSIGNED INTEGER)) AND config_id=(
              # Returns config_id value containing active_set definition
              SELECT
                MAX(config_id) config_id
                FROM configuration
                WHERE CAST(config_set AS UNSIGNED INTEGER)=0
                  AND NOT(CAST(group_id AS UNSIGNED INTEGER))
                  AND LOWER(config_label)="active_set")) ;
      END ;;
    DELIMITER ;
  # F_config_boolean
    DROP FUNCTION IF EXISTS `F_config_boolean`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_boolean`
        (`inval` VARCHAR(63))
      RETURNS int
      READS SQL DATA
      DETERMINISTIC
        BEGIN
          RETURN (F_boolean(F_config_text(inval)));
        END ;;
    DELIMITER ;
  # F_config_boolean_group
    DROP FUNCTION IF EXISTS `F_config_boolean_group`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_boolean_group`
        (`i_group_id` INT, `inval` VARCHAR(63))
      RETURNS int
      READS SQL DATA
      DETERMINISTIC
        BEGIN
          RETURN (F_boolean(F_config_text_group(i_group_id,inval)));
        END ;;
    DELIMITER ;
  # F_config_date
    DROP FUNCTION IF EXISTS `F_config_date`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_date`
        (`i_config_label` VARCHAR(63))
      RETURNS date
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT STR_TO_DATE(config_value,'%Y-%m-%d') config_value
          FROM configuration
          WHERE config_id=( SELECT
              if ( max(config_id) IS NULL,
                ( SELECT max(config_id) config_id
                  FROM configuration
                  WHERE CAST(config_set AS UNSIGNED INTEGER)=0
                    AND NOT(CAST(group_id AS UNSIGNED INTEGER))
                    AND LOWER(config_label)=LOWER(i_config_label)),
                max(config_id)) config_id
              FROM configuration
              WHERE CAST(config_set AS UNSIGNED INTEGER)=F_config_active_set()
                AND NOT(CAST(group_id AS UNSIGNED INTEGER))
                AND LOWER(config_label)=LOWER(i_config_label))
            AND NOT(CAST(group_id AS UNSIGNED INTEGER))) ;
      END ;;
    DELIMITER ;
  # F_config_date_end
    DROP FUNCTION IF EXISTS `F_config_date_end`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_date_end`()
      RETURNS date
      NO SQL
      DETERMINISTIC
      BEGIN
        IF (F_config_boolean("use_static_dates"))
        THEN
          RETURN(F_config_date("static_date_end"));
        ELSE
          RETURN(F_config_dynamic_date_end());
        END IF ;
      END ;;
    DELIMITER ;
  # F_config_date_group
    DROP FUNCTION IF EXISTS `F_config_date_group`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_date_group`
      (`i_group_id` INT, `i_config_label` VARCHAR(63))
      RETURNS DATE
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT config_value
          FROM `configuration`
          WHERE config_set=F_config_active_set()
            AND LOWER(config_label)=LOWER(i_config_label)
            AND group_id=i_group_id);
      END ;;
    DELIMITER ;
  # F_config_date_start
    DROP FUNCTION IF EXISTS `F_config_date_start`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_date_start`() RETURNS date
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        IF (F_config_boolean("use_static_dates"))
        THEN
          RETURN(F_config_date("static_date_start"));
        ELSE
          RETURN(F_config_dynamic_date_start());
        END IF ;
      END ;;
    DELIMITER ;
  # F_config_dynamic_date_end
    DROP FUNCTION IF EXISTS `F_config_dynamic_date_end`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_dynamic_date_end`()
      RETURNS date
      NO SQL
      DETERMINISTIC
      BEGIN
        RETURN(date_add(F_config_dynamic_date_start(),
          INTERVAL f_config_int("end_days_after_start") DAY)) ;
      END ;;
    DELIMITER ;
  # F_config_dynamic_date_start
    DROP FUNCTION IF EXISTS `F_config_dynamic_date_start`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `F_config_dynamic_date_start`()
      RETURNS date
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(date_add(date(now()),
          INTERVAL f_config_int("start_days_after_today") DAY)) ;
      END ;;
    DELIMITER ;
  # F_config_int
    DROP FUNCTION IF EXISTS `F_config_int`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_int`
      (`i_config_label` VARCHAR(63))
      RETURNS int
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT CAST(config_value AS UNSIGNED INTEGER) config_value
        FROM `configuration`
        WHERE config_id=(
          SELECT
            if ( max(config_id) IS NULL,
              ( SELECT max(config_id) config_id
                FROM configuration
                WHERE CAST(config_set AS UNSIGNED INTEGER)=0
                  AND NOT(CAST(group_id AS UNSIGNED INTEGER))
                  AND LOWER(config_label)=LOWER(i_config_label) ),
              max(config_id)) config_id
          FROM configuration
          WHERE CAST(config_set AS UNSIGNED INTEGER)=F_config_active_set()
            AND LOWER(config_label)=LOWER(i_config_label)
            AND NOT(CAST(group_id AS UNSIGNED INTEGER))
          ) AND NOT(CAST(group_id AS UNSIGNED INTEGER))) ;
      END ;;
    DELIMITER ;
  # F_config_int_group
    DROP FUNCTION IF EXISTS `F_config_int_group`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_int_group`
      (`i_group_id` INT, `i_config_label` VARCHAR(63))
      RETURNS INT
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT CAST(config_value AS UNSIGNED INTEGER)
          FROM `configuration`
          WHERE config_set=F_config_active_set()
            AND LOWER(config_label)=LOWER(i_config_label)
            AND group_id=i_group_id);
      END ;;
    DELIMITER ;
  # F_config_long_text
    DROP FUNCTION IF EXISTS `F_config_long_text`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_long_text`()
      RETURNS int
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        IF (LEFT(F_config_text("text_length"),2)="lo")
            THEN RETURN(1);
            ELSE RETURN(0);
            END IF ;
      END ;;
    DELIMITER ;
  # F_config_text
    DROP FUNCTION IF EXISTS `F_config_text`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_text`(`i_config_label` VARCHAR(63))
      RETURNS varchar(31)
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT lower(config_value) config_value
        FROM configuration
        WHERE config_id=(
          SELECT
            if ( max(config_id) IS NULL,
              ( SELECT max(config_id) config_id
                FROM configuration
                WHERE CAST(config_set AS UNSIGNED INTEGER)=0
                  AND NOT(CAST(group_id AS UNSIGNED INTEGER))
                  AND LOWER(config_label)=LOWER(i_config_label) ),
              max(config_id)) config_id
          FROM configuration
          WHERE CAST(config_set AS UNSIGNED INTEGER)=F_config_active_set()
            AND LOWER(config_label)=LOWER(i_config_label)
            AND NOT(CAST(group_id AS UNSIGNED INTEGER))
          ) AND NOT(CAST(group_id AS UNSIGNED INTEGER))) ;
      END ;;
    DELIMITER ;
  # F_config_text_group
    DROP FUNCTION IF EXISTS `F_config_text_group`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_config_text_group`
      (i_group_id INT, i_config_label VARCHAR(63))
      RETURNS varchar(31)
      READS SQL DATA
      DETERMINISTIC
      BEGIN
        RETURN(SELECT lower(config_value) config_value
        FROM configuration
        WHERE config_id=(
          SELECT
            if ( max(config_id) IS NULL,
              (
                SELECT
                  max(config_id) config_id
                FROM configuration
                WHERE CAST(config_set AS UNSIGNED INTEGER)=0
                  AND group_id=i_group_id
                  AND LOWER(config_label)=LOWER(i_config_label)
              ),
              max(config_id)) config_id
          FROM configuration
          WHERE CAST(config_set AS UNSIGNED INTEGER)=F_config_active_set()
            AND LOWER(config_label)=LOWER(i_config_label)
            AND group_id=i_group_id
          ) AND group_id=i_group_id) ;
      END ;;
    DELIMITER ;
  # F_count_of_options
    DROP FUNCTION IF EXISTS `F_count_of_options`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_count_of_options`
      (`i_lectionary_year_id` INT, `i_proper_id` INT, `i_citation_usage_id` INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'Returns the number of options offered for a given year/proper/usage.'
      BEGIN
        RETURN (SELECT MAX(F_enum2int(l.citation_option_index))
          FROM lectionary_contents l
          WHERE l.`lectionary_id`=F_config_int("lectionary_id")
            AND l.lectionary_year_id=i_lectionary_year_id
            AND l.proper_id=i_proper_id
            AND l.citation_usage_id=i_citation_usage_id
          GROUP BY l.lectionary_year_id,l.proper_id,l.citation_usage_id)+1;
      END ;;
    DELIMITER ;
  # F_Date_1_Advent
    DROP FUNCTION IF EXISTS `F_Date_1_Advent`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_Date_1_Advent`(year_in int) RETURNS date
        DETERMINISTIC
    BEGIN
    RETURN MAKEDATE(year_in,DAYOFYEAR(CONCAT(year_in,'-12-04'))
      - (WEEKDAY(MAKEDATE(year_in,DAYOFYEAR(CONCAT(year_in,'-12-04')))))-1);
    END ;;
    DELIMITER ;
  # F_DateOfEaster
    DROP FUNCTION IF EXISTS `F_DateOfEaster`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_DateOfEaster`
      (`iYear` varchar(255))
      RETURNS DATE
      DETERMINISTIC
      COMMENT 'This is a comment.'
      BEGIN
        SET @iD=0,@iE=0,@iQ=0,@iMonth=0,@iDay=0;
        SET @iD = 255 - 11 * (iYear % 19);
        SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
        SET @iD = @iD - IF(@iD > 48, 1 ,0);
        SET @iE = (iYear + FLOOR(iYear/4) + @iD + 1) % 7;
        SET @iQ = @iD + 7 - @iE;
        IF @iQ < 32 THEN
        SET @iMonth = 3;
        SET @iDay = @iQ;
        ELSE
        SET @iMonth = 4;
        SET @iDay = @iQ - 31;
        END IF;
        RETURN STR_TO_DATE(CONCAT(iYear,'-',@iMonth,'-',@iDay),'%Y-%m-%d');
      END ;;
    DELIMITER ;
  # F_enum2int
    DROP FUNCTION IF EXISTS `F_enum2int`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `F_enum2int`
    (`i_val` enum('0','1','2','3','4','5','6','7','8','9'))
    RETURNS int
    DETERMINISTIC
    RETURN(CAST(CAST(i_val AS CHAR) AS UNSIGNED INTEGER)) ;;
    DELIMITER ;
  # F_get_text_id
    DROP FUNCTION IF EXISTS `F_get_text_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_get_text_id`
      (`i_citation_id` INT, `i_citation_usage_id` INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'Returns text_id; adjusts for California and Override 4'
      BEGIN
        SET @typeval=(
          SELECT t.text_id
          FROM texts t
          WHERE t.citation_id=i_citation_id
            AND t.text_type_id=F_california_text_type(i_citation_id,
              F_map_text_type(i_citation_id,i_citation_usage_id)));
        IF ISNULL(@typeval)
          THEN SET @typeval=(
            SELECT t.text_id
            FROM texts t
            WHERE t.citation_id=i_citation_id);
          END IF;
        RETURN(@typeval);
      END ;;
    DELIMITER ;
  # F_get_text_length
    DROP FUNCTION IF EXISTS `F_get_text_length`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_get_text_length`
      (`i_citation_id` INT, `i_citation_usage_id` INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'This is a comment.'
      BEGIN
      RETURN (
        SELECT LENGTH(t.text_content)
        FROM texts t
        WHERE t.citation_id=i_citation_id
          AND t.text_type_id=F_california_text_type(i_citation_id,
            F_map_text_type(i_citation_id,i_citation_usage_id)));
      END ;;
    DELIMITER ;
  # F_in_date_range
    DROP FUNCTION IF EXISTS `F_in_date_range`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_in_date_range`
      (`iTestDate` DATE, `iEve` INT,
        iStartMonth INT, iStartDay INT,
        iEndMonth INT, iEndDay INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'Determines whether iTestDate lies within a specified range'
      BEGIN
        IF iEve THEN SET iTestDate=DATE_SUB(iTestDate,INTERVAL 1 DAY); END IF;
        SET @iStartDate=DATE(CONCAT_WS('-', YEAR(iTestDate),
          iStartMonth, iStartDay));
        SET @iEndDate=DATE(CONCAT_WS('-', YEAR(iTestDate),
          iEndMonth, iEndDay));
        IF @iEndDate<@iStartDate THEN
          IF iTestDate<=@iEndDate OR iTestDate>=@iStartDate
            THEN RETURN(TRUE);
            ELSE RETURN(FALSE);
            END IF;
          ELSE IF iTestDate BETWEEN @iStartDate AND @iEndDate
            THEN RETURN(TRUE);
            END IF;
          END IF;
        RETURN(FALSE);
      END ;;
    DELIMITER ;
  # F_is_song
    DROP FUNCTION IF EXISTS `F_is_song`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_is_song`
      (`i_citation_usage_id` INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'Returns TRUE if the citation usage is used as a song (Psalm)'
      BEGIN
      RETURN (i_citation_usage_id=1
        OR i_citation_usage_id=4
        OR i_citation_usage_id=6
        OR i_citation_usage_id=8
        OR i_citation_usage_id=10
        OR i_citation_usage_id=12
        OR i_citation_usage_id=14
        OR i_citation_usage_id=16
        OR i_citation_usage_id=18
        OR i_citation_usage_id=20
        OR i_citation_usage_id=22);
      END ;;
    DELIMITER ;
  # F_map_citation_source_id
    DROP FUNCTION IF EXISTS `F_map_citation_source_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_map_citation_source_id`(`i_citation_source_id` int ) RETURNS int
        DETERMINISTIC
    IF (SELECT
            m.citation_source_id
          FROM text_type_maps m
          WHERE m.citation_source_id=i_citation_source_id )
          THEN
            RETURN(i_citation_source_id);
          ELSE
            RETURN(NULL);
          END IF ;;
    DELIMITER ;
  # F_map_citation_usage_id
    DROP FUNCTION IF EXISTS `F_map_citation_usage_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_map_citation_usage_id`(`i_citation_usage_id` int ) RETURNS int
        DETERMINISTIC
    IF (SELECT
            u.song_form
          FROM citation_usages u
          WHERE u.song_form=i_citation_usage_id AND u.song_form=1 )
          THEN
            RETURN(i_citation_usage_id);
          ELSE
            RETURN(NULL);
          END IF ;;
    DELIMITER ;
  # F_map_text_type
    DROP FUNCTION IF EXISTS `F_map_text_type`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_map_text_type`
    (`i_citation_id` int, `i_citation_usage_id` INT )
    RETURNS int
      DETERMINISTIC
      BEGIN
        SET @iVal=(SELECT
          if(m1.text_type_id IS NULL,m2.text_type_id,m1.text_type_id)
            text_type_id
          FROM citations c
          LEFT JOIN citation_usages u
            ON u.citation_usage_id=i_citation_usage_id
          LEFT JOIN text_type_maps m1
            ON m1.citation_source_id=c.citation_source_id
          LEFT JOIN text_type_maps m2
            ON m2.song_form=u.song_form
          WHERE c.citation_id=i_citation_id
          );
        SET @iOverride=(SELECT
          o.text_type_id_out
          FROM `_configuration` o
          WHERE o.override_type_id=4
            # AND o.config_set_id=F_config_active_set()
            AND o.citation_id_in=i_citation_id);
        SET @iTest=(SELECT t.text_id FROM texts t
          WHERE t.citation_id=i_citation_id AND t.text_type_id=530);
        IF (@iVal=530 AND ISNULL(@iTest))
          THEN SET @iVal=500;
          END IF;
        IF (NOT(ISNULL(@iOverride)))
          THEN SET @iVal=@iOverride;
          END IF;
        RETURN (@iVal);
      END ;;
    DELIMITER ;
  # F_max_citation_option_index
    DROP FUNCTION IF EXISTS `F_max_citation_option_index`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_max_citation_option_index`(`i_proper_id` INT,
        `i_lectionary_year_id` INT, `i_citation_usage` INT, `i_alt_rite` INT) RETURNS int
        DETERMINISTIC
    RETURN(
          SELECT MAX(m.citation_option_index) FROM (
            SELECT DISTINCT
              l.citation_option_index,
              F_override_filters_1_and_2(l.proper_id,l.lectionary_year_id,
                l.lectionary_track_id,l.citation_usage_id,l.rite_id,l.citation_id)
                citation_id,
              F_citation_length(F_override_filters_1_and_2(l.proper_id,
                l.lectionary_year_id,l.lectionary_track_id,l.citation_usage_id,
                l.rite_id,l.citation_id)) citation_length
            FROM lectionary_contents l
            WHERE l.lectionary_id=F_config_int("lectionary_id")
              AND l.proper_id=i_proper_id
              AND l.lectionary_year_id=i_lectionary_year_id
              AND (l.lectionary_track_id=0
                OR l.lectionary_track_id=F_track_id(i_proper_id,
                  i_lectionary_year_id))
              AND l.citation_usage_id=i_citation_usage
              AND (F_config_boolean("use_lane_shortened_citations")
                OR l.lane_extension)
              AND if(i_alt_rite,
                l.rite_id=if(F_config_int("rite_id")=1,2,
                  if(F_config_int("rite_id")=2,1,0)),
                    (l.rite_id=0 OR l.rite_id=F_config_int("rite_id")))
            ) m
          ) ;;
    DELIMITER ;
  # F_max_track_id
    DROP FUNCTION IF EXISTS `F_max_track_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_max_track_id`(`i_proper_id` INT, `i_lectionary_year_id` INT) RETURNS int
        DETERMINISTIC
    RETURN(
            SELECT DISTINCT
              max(l.lectionary_track_id) lectionary_track_id
            FROM lectionary_contents l
            WHERE l.proper_id=i_proper_id
              AND l.lectionary_year_id=i_lectionary_year_id
            GROUP BY l.proper_id,l.lectionary_year_id
            ) ;;
    DELIMITER ;
  # F_most_recent_observance_date
    DROP FUNCTION IF EXISTS `F_most_recent_observance_date`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_most_recent_observance_date`
      (`iDate` DATE)
      RETURNS DATE
      DETERMINISTIC
      BEGIN
        RETURN(SELECT
          max(obs_date)
          FROM `____primary_daily_observances`
          WHERE obs_date<=iDate);
      END ;;
    DELIMITER ;
  # F_multiTrim
    DROP FUNCTION IF EXISTS `F_multiTrim`;
    # From https://newbedev.com/does-the-mysql-trim-function-not-trim-line-breaks-or-carriage-returns
    # Sample usage: select F_multiTrim(string,"\r\n\t ");
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_multiTrim`
      (string varchar(1023),remove varchar(63))
      RETURNS varchar(1023)
      DETERMINISTIC
      COMMENT 'Trims muitiple characters before and after a string.'
      BEGIN
        -- Remove trailing chars
        WHILE length(string)>0 and remove LIKE concat('%',substring(string,-1),'%') DO
          set string = substring(string,1,length(string)-1);
        END WHILE;
        -- Remove leading chars
        WHILE length(string)>0 and remove LIKE concat('%',left(string,1),'%') DO
          set string = substring(string,2);
        END WHILE;
        RETURN string;
      END ;;
    DELIMITER ;
  # F_Observance
    DROP FUNCTION IF EXISTS `F_Observance`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_Observance`
      (`iDate` DATE)
      RETURNS varchar(64)
      DETERMINISTIC
      COMMENT 'This is a comment.'
      BEGIN
        SET @WeekdaySunday = 6;
        IF WEEKDAY(iDate) = @WeekdaySunday THEN
          SET @DayOfYear=DAYOFYEAR(iDate);
          IF @DayOfYear<6 THEN RETURN("2 Christmas"); END IF;
          IF @DayOfYear=6 THEN RETURN("Epiphany"); END IF;
          SET @Result=CONCAT(FLOOR(@DayOfYear/7)," Epiphany");
          SET @NextResult=CASE
            FLOOR(@DayOfYear-(DAYOFYEAR(F2DateOfEaster(YEAR(iDate)))-56))/7
              WHEN 1 THEN "Last Epiphany"
              WHEN 2 THEN "1 Lent"
              WHEN 3 THEN "2 Lent"
              WHEN 4 THEN "3 Lent"
              WHEN 5 THEN "4 Lent"
              WHEN 6 THEN "5 Lent"
              WHEN 7 THEN "Palm Sunday"
              WHEN 8 THEN "Easter Day"
              WHEN 9 THEN "2 Easter"
              WHEN 10 THEN "3 Easter"
              WHEN 11 THEN "4 Easter"
              WHEN 12 THEN "5 Easter"
              WHEN 13 THEN "6 Easter"
              WHEN 14 THEN "7 Easter"
              WHEN 15 THEN "Pentecost Day"
              WHEN 16 THEN "Trinity Sunday"
              WHEN 17 THEN "2 Pentecost"
              WHEN 18 THEN "3 Pentecost"
              WHEN 19 THEN "4 Pentecost"
              WHEN 20 THEN "5 Pentecost"
              WHEN 21 THEN "6 Pentecost"
              WHEN 22 THEN "7 Pentecost"
              WHEN 23 THEN "8 Pentecost"
              WHEN 24 THEN "9 Pentecost"
              WHEN 25 THEN "10 Pentecost"
              WHEN 26 THEN "11 Pentecost"
              WHEN 27 THEN "12 Pentecost"
              WHEN 28 THEN "13 Pentecost"
              WHEN 29 THEN "14 Pentecost"
              WHEN 30 THEN "15 Pentecost"
              WHEN 31 THEN "16 Pentecost"
              WHEN 32 THEN "17 Pentecost"
              WHEN 33 THEN "18 Pentecost"
              WHEN 34 THEN "19 Pentecost"
              WHEN 35 THEN "20 Pentecost"
              WHEN 36 THEN "21 Pentecost"
              WHEN 37 THEN "22 Pentecost"
              WHEN 38 THEN "23 Pentecost"
              WHEN 39 THEN "24 Pentecost"
              WHEN 40 THEN "25 Pentecost"
              WHEN 41 THEN "26 Pentecost"
              WHEN 42 THEN "27 Pentecost"
          END;
          SET @Result=IF(ISNULL(@NextResult),@Result,@NextResult);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>19,"Last Pentecost",@Result);
          SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>26,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12,"1 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>3,"2 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>10,"3 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>17,"4 Advent",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)=25,"Christmas",@Result);
          SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>25,"1 Christmas",@Result);
          RETURN(@Result);
        ELSE
          RETURN("Non-Sunday");
        END IF;
      END ;;
    DELIMITER ;
  # F_ObservanceDefault
        DROP FUNCTION IF EXISTS `F_ObservanceDefault`;
        DELIMITER ;;
        CREATE DEFINER=`root`@`localhost` FUNCTION `F_ObservanceDefault`
          (`iDate` DATE)
          RETURNS varchar(64)
          DETERMINISTIC
          COMMENT 'This is a comment.'
          BEGIN
            SET @WeekdaySunday = 6;
            IF WEEKDAY(iDate) = @WeekdaySunday THEN
              SET @DayOfYear=DAYOFYEAR(iDate);
              IF @DayOfYear<6 THEN RETURN("2 Christmas"); END IF;
              IF @DayOfYear=6 THEN RETURN("Epiphany"); END IF;
              SET @Result=CONCAT(FLOOR(@DayOfYear/7)," Epiphany");
              SET @NextResult=CASE
                FLOOR(@DayOfYear-(DAYOFYEAR(F2DateOfEaster(YEAR(iDate)))-56))/7
                  WHEN 1 THEN "Last Epiphany"
                  WHEN 2 THEN "1 Lent"
                  WHEN 3 THEN "2 Lent"
                  WHEN 4 THEN "3 Lent"
                  WHEN 5 THEN "4 Lent"
                  WHEN 6 THEN "5 Lent"
                  WHEN 7 THEN "Palm Sunday"
                  WHEN 8 THEN "Easter Day"
                  WHEN 9 THEN "2 Easter"
                  WHEN 10 THEN "3 Easter"
                  WHEN 11 THEN "4 Easter"
                  WHEN 12 THEN "5 Easter"
                  WHEN 13 THEN "6 Easter"
                  WHEN 14 THEN "7 Easter"
                  WHEN 15 THEN "Pentecost Day"
                  WHEN 16 THEN "Trinity Sunday"
                  WHEN 17 THEN "2 Pentecost"
                  WHEN 18 THEN "3 Pentecost"
                  WHEN 19 THEN "4 Pentecost"
                  WHEN 20 THEN "5 Pentecost"
                  WHEN 21 THEN "6 Pentecost"
                  WHEN 22 THEN "7 Pentecost"
                  WHEN 23 THEN "8 Pentecost"
                  WHEN 24 THEN "9 Pentecost"
                  WHEN 25 THEN "10 Pentecost"
                  WHEN 26 THEN "11 Pentecost"
                  WHEN 27 THEN "12 Pentecost"
                  WHEN 28 THEN "13 Pentecost"
                  WHEN 29 THEN "14 Pentecost"
                  WHEN 30 THEN "15 Pentecost"
                  WHEN 31 THEN "16 Pentecost"
                  WHEN 32 THEN "17 Pentecost"
                  WHEN 33 THEN "18 Pentecost"
                  WHEN 34 THEN "19 Pentecost"
                  WHEN 35 THEN "20 Pentecost"
                  WHEN 36 THEN "21 Pentecost"
                  WHEN 37 THEN "22 Pentecost"
                  WHEN 38 THEN "23 Pentecost"
                  WHEN 39 THEN "24 Pentecost"
                  WHEN 40 THEN "25 Pentecost"
                  WHEN 41 THEN "26 Pentecost"
                  WHEN 42 THEN "27 Pentecost"
              END;
              SET @Result=IF(ISNULL(@NextResult),@Result,@NextResult);
              SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>19,"Last Epiphany",@Result);
              SET @Result=IF(MONTH(iDate)=11 AND DAY(iDate)>26,"1 Advent",@Result);
              SET @Result=IF(MONTH(iDate)=12,"1 Advent",@Result);
              SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>3,"2 Advent",@Result);
              SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>10,"3 Advent",@Result);
              SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>17,"4 Advent",@Result);
              SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)=25,"Christmas",@Result);
              SET @Result=IF(MONTH(iDate)=12 AND DAY(iDate)>25,"1 Christmas",@Result);
              RETURN(@Result);
            ELSE
              RETURN("Non-Sunday");
            END IF;
          END ;;
        DELIMITER ;
  # F_other_rite
    DROP FUNCTION IF EXISTS `F_other_rite`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      FUNCTION `F_other_rite`(`i_rite` int)
      RETURNS int
      DETERMINISTIC
      BEGIN
        IF (i_rite=1)
        THEN RETURN(2);
        ELSE
          IF (i_rite=2)
          THEN RETURN(1);
          ELSE RETURN(0);
          END IF;
        END IF ;
      END ;;
    DELIMITER ;
  # F_override
    DROP FUNCTION IF EXISTS `F_override`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_override`
      (`i_obs_date` DATE, `i_proper_id` INT,
        `i_lectionary_year_id` INT, `i_citation_usage` INT,
        `i_alt_rite` INT)
      RETURNS int
      DETERMINISTIC
      COMMENT 'This is a comment.'
      BEGIN
        RETURN(
          SELECT min(m.citation_length) FROM (
            SELECT DISTINCT
              F_override_filters_1_and_2(l.proper_id,l.lectionary_year_id,
                l.lectionary_track_id,l.citation_usage_id,l.rite_id,l.citation_id)
                citation_id,
              F_citation_length(F_override_filters_1_and_2(l.proper_id,
                l.lectionary_year_id,l.lectionary_track_id,l.citation_usage_id,
                l.rite_id,l.citation_id)) citation_length
            FROM lectionary_contents l
            WHERE l.lectionary_id=F_config_int("lectionary_id")
              AND l.proper_id=i_proper_id
              AND l.lectionary_year_id=i_lectionary_year_id
              AND (l.lectionary_track_id=0
                OR l.lectionary_track_id=F_track_id(i_proper_id,
                  i_lectionary_year_id))
              AND l.citation_usage_id=i_citation_usage
              AND (F_config_boolean("use_lane_shortened_citations")
                OR l.lane_extension)
              AND if(i_alt_rite,
                l.rite_id=if(F_config_int("rite_id")=1,2,
                  if(F_config_int("rite_id")=2,1,0)),
                    (l.rite_id=0 OR l.rite_id=F_config_int("rite_id")))
              AND cast(cast(l.citation_option_index AS CHAR) AS UNSIGNED INTEGER)
                =MOD(YEAR(i_obs_date),
                F_max_citation_option_index(i_proper_id,i_lectionary_year_id,
                  i_citation_usage,i_alt_rite)+1)
            ) m
          );
      END ;;
    DELIMITER ;
  # F_override_1_if_exists
    DROP FUNCTION IF EXISTS `F_override_1_if_exists`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_override_1_if_exists`(`i_citation_id` INT) RETURNS int
        DETERMINISTIC
    RETURN(SELECT DISTINCT
      o.citation_id_out citation_id
    FROM `_configuration` o
    WHERE f_config_boolean("apply_overrides")
      # AND o.config_set_id=F_config_active_set()
      AND o.override_type_id=1
      AND o.citation_id_in=i_citation_id) ;;
    DELIMITER ;
  # F_override_2_filter
    DROP FUNCTION IF EXISTS `F_override_2_filter`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_override_2_filter`(`i_proper_id` INT, `i_lectionary_year_id` INT, `i_lectionary_track_id` INT, `i_citation_usage_id` INT, `i_rite_id` INT, `i_citation_id_in` INT) RETURNS int
        DETERMINISTIC
    IF (ISNULL(F_override_2_if_exists(i_proper_id, i_lectionary_year_id,
        i_lectionary_track_id, i_citation_usage_id, i_rite_id)))
      THEN
        RETURN (i_citation_id_in);
      ELSE
        RETURN (
          F_override_2_if_exists(i_proper_id, i_lectionary_year_id,
            i_lectionary_track_id, i_citation_usage_id, i_rite_id)
          );
      END IF ;;
    DELIMITER ;
  # F_override_2_if_exists
    DROP FUNCTION IF EXISTS `F_override_2_if_exists`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_override_2_if_exists`(`i_proper_id` INT, `i_lectionary_year_id` INT, `i_lectionary_track_id` INT, `i_citation_usage_id` INT, `i_rite_id` INT) RETURNS int
        DETERMINISTIC
    RETURN (
    SELECT DISTINCT
      o.citation_id_out citation_id
    FROM `_configuration` o
    WHERE f_config_boolean("apply_overrides")
      # AND o.config_set_id=F_config_active_set()
      AND o.override_type_id=2
      AND o.lectionary_id_in=F_config_int("lectionary_id")
      AND o.proper_id_in=i_proper_id
      AND o.lectionary_year_id_in=i_lectionary_year_id
      AND o.lectionary_track_id_in=i_lectionary_track_id
      AND o.citation_usage_in=i_citation_usage_id
      AND o.rite_id_in=i_rite_id
    ) ;;
    DELIMITER ;
  # F_override_4
      DROP FUNCTION IF EXISTS `F_override_4`;
      DELIMITER ;;
      CREATE DEFINER=`root`@`localhost` FUNCTION `F_override_4`
        (`i_citation_id` INT, i_default_text_type_id INT )
        RETURNS int
        DETERMINISTIC
        COMMENT 'This is a comment.'
        BEGIN
          IF (F_config_boolean("apply_overrides"))
            THEN SET @OR_TYPE=(SELECT
                c.text_type_id_out text_type_id
              FROM configuration c
              WHERE c.citation_id_in=i_citation_id
                AND c.config_set_id=F_config_active_set()
                AND c.config_type_id=4
                AND c.NOT(CAST(group_id AS UNSIGNED INTEGER))
              );
            END IF;
          IF (ISNULL(@OR_TYPE))
            THEN RETURN (i_default_text_type_id);
            ELSE RETURN (@OR_TYPE);
            END IF;
        END ;;
      DELIMITER ;
  # F_override_filters_1_and_2
    DROP FUNCTION IF EXISTS `F_override_filters_1_and_2`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_override_filters_1_and_2`(`i_proper_id` INT, `i_lectionary_year_id` INT, `i_lectionary_track_id` INT, `i_citation_usage_id` INT, `i_rite_id` INT, `i_citation_id_in` INT) RETURNS int
        DETERMINISTIC
    IF (ISNULL(F_override_1_if_exists(F_override_2_filter(i_proper_id,
        i_lectionary_year_id,i_lectionary_track_id,i_citation_usage_id,
        i_rite_id,i_citation_id_in))))
      THEN
        RETURN(F_override_2_filter(i_proper_id,i_lectionary_year_id,
          i_lectionary_track_id,i_citation_usage_id,i_rite_id,i_citation_id_in));
      ELSE
        RETURN(F_override_1_if_exists(F_override_2_filter(i_proper_id,
          i_lectionary_year_id,i_lectionary_track_id,i_citation_usage_id,
          i_rite_id,i_citation_id_in)));
      END IF ;;
    DELIMITER ;
  # F_shortest_text_length
    DROP FUNCTION IF EXISTS `F_shortest_text_length`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_shortest_text_length`
      (`i_citation_id` INT)
      RETURNS INT
      DETERMINISTIC
      COMMENT 'Returns the shortest text length available for a given citation.'
      BEGIN
        RETURN(SELECT MIN(LENGTH(t.text_content))
          FROM `texts` t
          WHERE t.citation_id=i_citation_id);
      END ;;
    DELIMITER ;
  # F_target_citation_length
    DROP FUNCTION IF EXISTS `F_target_citation_length`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_target_citation_length`(`i_obs_date` DATE, `i_proper_id` INT,
        `i_lectionary_year_id` INT, `i_citation_usage` INT, `i_alt_rite` INT) RETURNS int
        DETERMINISTIC
    RETURN(
            SELECT if (F_config_long_text(),max(m.citation_length),
                min(m.citation_length)) FROM (
              SELECT DISTINCT
                F_override_filters_1_and_2(l.proper_id,l.lectionary_year_id,
                  l.lectionary_track_id,l.citation_usage_id,l.rite_id,l.citation_id)
                  citation_id,
                F_citation_length(F_override_filters_1_and_2(l.proper_id,
                  l.lectionary_year_id,l.lectionary_track_id,l.citation_usage_id,
                  l.rite_id,l.citation_id)) citation_length
              FROM lectionary_contents l
              WHERE l.lectionary_id=F_config_int("lectionary_id")
                AND l.proper_id=i_proper_id
                AND l.lectionary_year_id=i_lectionary_year_id
                AND (l.lectionary_track_id=0
                  OR l.lectionary_track_id=F_track_id(i_proper_id,
                    i_lectionary_year_id))
                AND l.citation_usage_id=i_citation_usage
                AND (F_config_boolean("use_lane_shortened_citations")
                  OR l.lane_extension)
                AND if(i_alt_rite,
                  l.rite_id=if(F_config_int("rite_id")=1,2,
                    if(F_config_int("rite_id")=2,1,0)),
                      (l.rite_id=0 OR l.rite_id=F_config_int("rite_id")))
                AND cast(cast(l.citation_option_index AS CHAR) AS UNSIGNED INTEGER)
                  =MOD(YEAR(i_obs_date),
                  F_max_citation_option_index(i_proper_id,i_lectionary_year_id,
                    i_citation_usage,i_alt_rite)+1)
              ) m
            ) ;;
    DELIMITER ;
  # F_text_id
    DROP FUNCTION IF EXISTS `F_text_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_text_id`(`i_citation_id` INT) RETURNS int
        DETERMINISTIC
    RETURN(SELECT DISTINCT
      t.text_id
    FROM texts t
    LEFT JOIN citations c ON c.citation_id=t.citation_id
    WHERE t.citation_id=i_citation_id
      AND t.text_type_id=F_text_type_filtered(i_citation_id)) ;;
    DELIMITER ;
  # F_text_type_default
    DROP FUNCTION IF EXISTS `F_text_type_default`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_text_type_default`(`i_citation_id` INT) RETURNS int
        DETERMINISTIC
    RETURN(SELECT DISTINCT
      if (citation_source_id=290 OR citation_source_id=292,
        F_config_int("psalms_text_type_id"),
        if (citation_source_id=294,
          F_config_int("canticles_text_type_id"),
          F_config_int("scripture_text_type_id")))
      FROM citations
      WHERE citation_id=i_citation_id) ;;
    DELIMITER ;
  # F_text_type_filtered
    DROP FUNCTION IF EXISTS `F_text_type_filtered`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_text_type_filtered`(`i_citation_id` INT) RETURNS int
        DETERMINISTIC
    IF ((SELECT DISTINCT
        o.text_type_id_out
      FROM `_configuration` o
      WHERE f_config_boolean("apply_overrides")
        # AND o.config_set_id=F_config_active_set()
        AND o.override_type_id=4
        AND o.citation_id_in=i_citation_id) IS NULL)
    THEN
      RETURN(F_text_type_default(i_citation_id));
    ELSE
      RETURN(SELECT DISTINCT
          o.text_type_id_out
        FROM `_configuration` o
        WHERE f_config_boolean("apply_overrides")
          # AND o.config_set_id=F_config_active_set()
          AND o.override_type_id=4
          AND o.citation_id_in=i_citation_id);
    END IF ;;
    DELIMITER ;
  # F_this_track_id
    DROP FUNCTION IF EXISTS `F_this_track_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_this_track_id`(`i_proper_id` INT, `i_lectionary_year_id` INT) RETURNS int
        DETERMINISTIC
    if (F_max_track_id(i_proper_id,i_lectionary_year_id))
            THEN
              return (F_track_id(i_proper_id,i_lectionary_year_id));
            ELSE
              return(0);
            END IF ;;
    DELIMITER ;
  # F_track_id
    DROP FUNCTION IF EXISTS `F_track_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_track_id`(`i_proper_id` INT,
        `i_lectionary_year_id` INT) RETURNS int
        DETERMINISTIC
    RETURN(
            IF ((
              SELECT
                o.lectionary_track_id_out
              FROM `_configuration` o
              WHERE o.override_type_id=3
                # AND o.config_set_id=F_config_active_set()
                AND o.lectionary_id_in=F_config_int("lectionary_id")
                AND o.proper_id_in=i_proper_id
                AND o.lectionary_year_id_in=i_lectionary_year_id
          #    ) IS NULL, if(i_track_id,F_config_int("track_id"),i_track_id), (
          #    ) IS NULL, i_track_id, (
              ) IS NULL, F_config_int("track_id"), (
                SELECT
                  o.lectionary_track_id_out
                FROM `_configuration` o
                WHERE F_config_boolean("apply_overrides")
                  # AND o.config_set_id=F_config_active_set()
                  AND o.override_type_id=3
                  AND o.lectionary_id_in=F_config_int("lectionary_id")
                  AND o.proper_id_in=i_proper_id
                  AND o.lectionary_year_id_in=i_lectionary_year_id
                ))
            ) ;;
    DELIMITER ;
  # F_Year_Daily_Office
    DROP FUNCTION IF EXISTS `F_Year_Daily_Office`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_Year_Daily_Office`(datetime_in datetime) RETURNS varchar(2)
      DETERMINISTIC
      BEGIN
        DECLARE Advent1 date DEFAULT MAKEDATE(YEAR(datetime_in),
          DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04'))
            - (WEEKDAY(MAKEDATE(YEAR(datetime_in),
              DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04')))))-1);
        DECLARE year_out int DEFAULT year(datetime_in);
        IF datetime_in >= Advent1 THEN
          SET year_out=year_out+1;
          END IF;
        SET year_out = MOD(year_out,2);
        IF year_out = 1 THEN
          RETURN('1');
          END IF;
        RETURN('2');
      END ;;
    DELIMITER ;
  # F_Year_Eucharist
    DROP FUNCTION IF EXISTS `F_Year_Eucharist`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_Year_Eucharist`(datetime_in datetime) RETURNS varchar(2)
        DETERMINISTIC
    BEGIN
    DECLARE Advent1 date DEFAULT MAKEDATE(YEAR(datetime_in),
      DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04'))
        - (WEEKDAY(MAKEDATE(YEAR(datetime_in),
          DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04')))))-1);
    DECLARE year_out int DEFAULT year(datetime_in);
    IF datetime_in >= Advent1 THEN
      SET year_out=year_out+1;
      END IF;
    SET year_out = MOD(year_out,3);
    IF year_out = 1 THEN
      RETURN('A');
      END IF;
    IF year_out = 2 THEN
      RETURN('B');
      END IF;
    RETURN('C');
    END ;;
    DELIMITER ;
  # F_Year_id_Eucharist
    DROP FUNCTION IF EXISTS `F_Year_id_Eucharist`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `F_Year_id_Eucharist`(`datetime_in` DATETIME) RETURNS int
        DETERMINISTIC
    BEGIN
    DECLARE Advent1 date DEFAULT MAKEDATE(YEAR(datetime_in),
      DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04'))
        - (WEEKDAY(MAKEDATE(YEAR(datetime_in),
          DAYOFYEAR(CONCAT(YEAR(datetime_in),'-12-04')))))-1);
    DECLARE year_out int DEFAULT year(datetime_in);
    IF datetime_in >= Advent1 THEN
      SET year_out=year_out+1;
      END IF;
    SET year_out = MOD(year_out,3);
    IF year_out = 1 THEN
      RETURN(11);
      END IF;
    IF year_out = 2 THEN
      RETURN(12);
      END IF;
    RETURN(13);
    END ;;
    DELIMITER ;
  # get_parameter
    DROP FUNCTION IF EXISTS `get_parameter`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `get_parameter`(iPName CHAR(30)) RETURNS char(127)
        DETERMINISTIC
    BEGIN
    RETURN ( SELECT `pValue` FROM `_parameters` WHERE `pName` = iPName );
    END ;;
    DELIMITER ;
  # location
    DROP FUNCTION IF EXISTS `location`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `location`(iLocation VARCHAR(12), iDateTime DATETIME,
      iObservance VARCHAR(30), iService VARCHAR(30))
    RETURNS varchar(12)
    DETERMINISTIC
    BEGIN
      IF (iLocation)
        THEN RETURN (iLocation);
        ELSE IF (weekday(iDateTime)=1 and hour(iDateTime)=11)
          THEN RETURN ('Carlotta');
          ELSE IF ((weekday(iDateTime)=2 and hour(iDateTime)=10
            and iObservance<>'Ash Wednesday'
            and left(iObservance,9)<>'Christmas')
            or (weekday(iDateTime)=3 and iService='MP2')
            or (weekday(iDateTime)=5 and hour(iDateTime)=17))
              THEN RETURN ('Chapel');
              ELSE           IF (hour(iDateTime)=10 AND weekday(iDateTime)<>6 AND iObservance<>'Ash Wednesday'
                    AND iObservance<>'Thanksgiving Day' AND iObservance<>'Christmas')
                  THEN RETURN ('Chapel');
                  ELSE               IF (iObservance='Ash Wednesday' and hour(iDateTime)=11)
                      THEN RETURN ('Public');
                      ELSE                   IF (iObservance='Ash Wednesday' and hour(iDateTime)=9)
                        THEN RETURN ('Mass/Mtn');
                        ELSE                     IF (hour(iDateTime)<>8 AND hour(iDateTime)<>10 AND weekday(iDateTime)=6
                              AND month(iDateTime)>=5 AND month(iDateTime)<=10)
                            THEN RETURN ('Karns');
                              ELSE                         RETURN ('Nave');
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
      END IF;
    END ;;
    DELIMITER ;
  # pop_form
    DROP FUNCTION IF EXISTS `pop_form`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `pop_form`(iPOPForm INT, iDateTime DATETIME, iRite VARCHAR(2),
      iObservance VARCHAR(40), iSeason VARCHAR(30), iService VARCHAR(30)) RETURNS int
        DETERMINISTIC
    BEGIN
      IF (iPOPForm)   THEN RETURN (iPOPForm);
        ELSE IF iObservance='Ash Wednesday'
            OR iObservance='Good Friday'
            OR iObservance='Holy Saturday'
            OR iService='Stations'
            OR iService='Taizé'
            OR iService='MP'
            OR iService='MP2'
            OR iService='EP'
            OR iService='Evensong'
          THEN RETURN (Null);  ELSE IF IObservance='Thanksgiving Day'
              THEN RETURN (1098); ELSE IF iSeason='Advent'
                  OR iSeason='Holy Week'
                  OR iSeason='Eastertide'
                  OR iObservance='Trinity Sunday'
                  OR iObservance='Christmas Eve'
                  OR iObservance='Christmas'
                THEN RETURN (868); ELSE IF iObservance='Margaret'
                  THEN IF hour(iDateTime)=10
                    THEN RETURN (1128); ELSE RETURN (954); END IF;
                  ELSE IF iSeason='Lent'
                    THEN IF weekday(iDateTime)=5
                      THEN RETURN (869); ELSE RETURN (869); END IF;
                    ELSE IF iRite='1'
                      THEN RETURN (1126); ELSE RETURN (871); END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
          END IF;
        END IF;
    END ;;
    DELIMITER ;
  # print_gospel
    DROP FUNCTION IF EXISTS `print_gospel`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `print_gospel`(iLocation VARCHAR(12), iDateTime DATETIME,
      iObservance VARCHAR(30), iService VARCHAR(30))
    RETURNS varchar(8)
    DETERMINISTIC
    BEGIN
      IF ((Location (iLocation,iDateTime,iObservance,iService)='Nave')
        AND (HOUR (TIME (iDateTime)) > 8)
        AND (HOUR (TIME (iDateTime)) < 12)
        AND (iObservance<>'Ash Wednesday')
        AND (iObservance<>'Thanksgiving Day')
        AND (iObservance<>'Christmas Day')
        AND (iObservance<>'Holy Saturday'))
            THEN RETURN 'No';
            ELSE RETURN 'Yes';
            END IF;
    END ;;
    DELIMITER ;
  # proper_preface
    DROP FUNCTION IF EXISTS `proper_preface`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `proper_preface`(iProperPreface INT, iStandardPreface INT,
        iDateTime DATETIME, iEve INT, iRotaID INT)
    RETURNS int
    DETERMINISTIC
    BEGIN
      IF (iProperPreface) THEN
        RETURN (iProperPreface);
        ELSE IF (iStandardPreface=911) THEN
          IF WEEKDAY(iDateTime)=6 OR (WEEKDAY(iDateTime)=6 AND iEve) THEN
            RETURN (911+TRUNCATE(RAND(iRotaID)*3,0));
            ELSE RETURN (NULL);
            END IF;
          ELSE RETURN (iStandardPreface);
          END IF;
        END IF;
    END ;;
    DELIMITER ;
  # psalm_setting_id
    DROP FUNCTION IF EXISTS `psalm_setting_id`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `psalm_setting_id`(iPsalmSettingID INT, iUseBCP BIT, iDateTime DATETIME, iPsalmTextID INT) RETURNS int
        DETERMINISTIC
    BEGIN
      IF (iPsalmSettingID)
        THEN RETURN iPsalmSettingID;
        ELSE
          IF (use_bcp (iUseBCP, iDateTime)='Yes')
            THEN RETURN 2212;
            ELSE IF (iPsalmTextID=1086)
              THEN RETURN 2212;
              ELSE RETURN 2213;
              END IF;
            END IF;
        END IF;
    END ;;
    DELIMITER ;
  # rite
    DROP FUNCTION IF EXISTS `rite`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `rite`(iRite VARCHAR(2), iDateTime DATETIME) RETURNS varchar(2)
        DETERMINISTIC
    BEGIN
      IF (iRite)
        THEN RETURN(iRite);
        ELSE
        IF (weekday(iDateTime)=6 and hour(iDateTime)>=5 and hour(iDateTime)<9)
          THEN RETURN('1');

          ELSE RETURN('2');
        END IF;
      END IF;
    END ;;
    DELIMITER ;
  # F_season
    DROP FUNCTION IF EXISTS `season`;
    DROP FUNCTION IF EXISTS `F_season`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `F_season`(iDate DATE)
    RETURNS varchar(30)
    DETERMINISTIC
    BEGIN
      SET @iYear=YEAR(iDate);
      SET @iMonth=MONTH(iDate);
      SET @iDay=DAY(iDate);
      SET @iD=0,@iE=0,@iQ=0,@eMonth=0,@eDay=0;
      SET @iD = 255 - 11 * (@iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (@iYear + FLOOR(@iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
      SET @eMonth = 3;
      SET @eDay = @iQ;
      ELSE
      SET @eMonth = 4;
      SET @eDay = @iQ - 31;
      END IF;
      SET @ChristmasDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-25')));
      SET @AdventDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))
        -(1+weekday(makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))))));
      SET @EasterDate=STR_TO_DATE(CONCAT(@iYear,
        '-',@eMonth,'-',@eDay),'%Y-%m-%d');
      SET @PentecostDate=date_add(@EasterDate,interval 49 day);
      SET @HolyWeekDate=date_sub(@EasterDate,interval 7 day);
      SET @LentDate=date_sub(@EasterDate,interval 46 day);
      SET @EpiphanyDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-01-06')));
      IF iDate >= @ChristmasDate THEN
        SET @season='Christmastide';
        ELSE IF iDate >= @AdventDate THEN
          SET @season='Advent';
          ELSE IF iDate > @PentecostDate THEN
              SET @season='Season after Pentecost';
              ELSE IF iDate >= @EasterDate THEN
                SET @season='Eastertide';
                ELSE IF iDate >= @HolyWeekDate THEN
                  SET @season='Holy Week';
                  ELSE IF iDate >= @LentDate THEN
                    SET @season='Lent';
                    ELSE IF iDate >= @EpiphanyDate THEN
                      SET @season='Epiphanytide';
                      ELSE SET @season='Christmastide';
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
      RETURN @season;
    END ;;
    DELIMITER ;
  # season_by_date
    DROP FUNCTION IF EXISTS `season_by_date`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `season_by_date`(iDate DATE)
    RETURNS varchar(30)
    DETERMINISTIC
    BEGIN
      SET @iYear=YEAR(iDate);
      SET @iMonth=MONTH(iDate);
      SET @iDay=DAY(iDate);
      SET @iD=0,@iE=0,@iQ=0,@eMonth=0,@eDay=0;
      SET @iD = 255 - 11 * (@iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (@iYear + FLOOR(@iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
      SET @eMonth = 3;
      SET @eDay = @iQ;
      ELSE
      SET @eMonth = 4;
      SET @eDay = @iQ - 31;
      END IF;
      SET @ChristmasDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-25')));
      SET @AdventDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))
        -(1+weekday(makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))))));
      SET @EasterDate=STR_TO_DATE(CONCAT(@iYear,'-',
          @eMonth,'-',@eDay),'%Y-%m-%d');
      SET @PentecostDate=date_add(@EasterDate,interval 49 day);
      SET @HolyWeekDate=date_sub(@EasterDate,interval 7 day);
      SET @LentDate=date_sub(@EasterDate,interval 46 day);
      SET @EpiphanyDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-01-06')));
      IF iDate >= @ChristmasDate THEN
        SET @season_by_date='Christmastide';
        ELSE IF iDate >= @AdventDate THEN
          SET @season_by_date='Advent';
          ELSE IF iDate > @PentecostDate THEN
              SET @season_by_date='season_by_date after Pentecost';
              ELSE IF iDate >= @EasterDate THEN
                SET @season_by_date='Eastertide';
                ELSE IF iDate >= @HolyWeekDate THEN
                  SET @season_by_date='Holy Week';
                  ELSE IF iDate >= @LentDate THEN
                    SET @season_by_date='Lent';
                    ELSE IF iDate >= @EpiphanyDate THEN
                      SET @season_by_date='Epiphanytide';
                      ELSE SET @season_by_date='Christmastide';
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
      RETURN @season_by_date;
    END ;;
    DELIMITER ;
  # season_by_observance
    DROP FUNCTION IF EXISTS `season_by_observance`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `season_by_observance`(iDateTime DATETIME, iEve INT,
        iObservance VARCHAR(40)) RETURNS varchar(30)
    DETERMINISTIC
    BEGIN
      SET @iYear=YEAR(iDateTime);
      SET @iMonth=MONTH(iDateTime);
      SET @iDay=DAY(iDateTime);
      SET @iD=0,@iE=0,@iQ=0,@eMonth=0,@eDay=0;
      SET @iD = 255 - 11 * (@iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (@iYear + FLOOR(@iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
        SET @eMonth = 3;
        SET @eDay = @iQ;
      ELSE
        SET @eMonth = 4;
        SET @eDay = @iQ - 31;
      END IF;
      SET @ChristmasDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-25')));
      SET @AdventDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))
        -(1+weekday(makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))))));
      SET @EasterDate=STR_TO_DATE(CONCAT(@iYear,'-',
          @eMonth,'-',@eDay),'%Y-%m-%d');
      SET @PentecostDate=date_add(@EasterDate,interval 49 day);
      SET @HolyWeekDate=date_sub(@EasterDate,interval 7 day);
      SET @LentDate=date_sub(@EasterDate,interval 46 day);
      SET @EpiphanyDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-01-06')));
      IF (((iDateTime >= @ChristmasDate)
          OR ((iDateTime >= date_sub(@ChristmasDate,interval 1 day)) and iEve))
          OR ((iDateTime = @ChristmasDate-1)
          AND (left(iObservance,9)='Christmas'))) THEN
        SET @season_by_observance='Christmastide';
        ELSE IF ((iDateTime >= @AdventDate) or ((iDateTime >= date_sub(@AdventDate,interval 1 day)) and iEve)) THEN
          SET @season_by_observance='Advent';
          ELSE IF ((iDateTime > @PentecostDate) or ((iDateTime >= @PentecostDate) and iEve)) THEN
              SET @season_by_observance='Season after Pentecost';
              ELSE IF (((iDateTime >= @EasterDate) or ((iDateTime >= date_sub(@EasterDate,interval 1 day)) and iEve))
                  OR ((iDateTime = @EasterDate-1) and (left(iObservance,6)='Easter'))) THEN
                SET @season_by_observance='Eastertide';
                ELSE IF ((iDateTime >= @HolyWeekDate) or ((iDateTime >= date_sub(@HolyWeekDate,interval 1 day)) and iEve)) THEN
                  SET @season_by_observance='Holy Week';
                  ELSE IF ((iDateTime >= @LentDate) or ((iDateTime >= date_sub(@LentDate,interval 1 day)) and iEve)) THEN
                    SET @season_by_observance='Lent';
                    ELSE IF ((iDateTime >= @EpiphanyDate) or ((iDateTime >= date_sub(@EpiphanyDate,interval 1 day)) and iEve)) THEN
                      SET @season_by_observance='Epiphanytide';
                      ELSE SET @season_by_observance='Christmastide';
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
      RETURN @season_by_observance;
    END ;;
    DELIMITER ;
  # season_color
    DROP FUNCTION IF EXISTS `season_color`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost` FUNCTION `season_color`(iDate DATE)
    RETURNS varchar(30)
    DETERMINISTIC
    BEGIN
      SET @iYear=YEAR(iDate);
      SET @iMonth=MONTH(iDate);
      SET @iDay=DAY(iDate);
      SET @iD=0,@iE=0,@iQ=0,@eMonth=0,@eDay=0;
      SET @iD = 255 - 11 * (@iYear % 19);
      SET @iD = IF (@iD > 50,(@iD-21) % 30 + 21,@iD);
      SET @iD = @iD - IF(@iD > 48, 1 ,0);
      SET @iE = (@iYear + FLOOR(@iYear/4) + @iD + 1) % 7;
      SET @iQ = @iD + 7 - @iE;
      IF @iQ < 32 THEN
      SET @eMonth = 3;
      SET @eDay = @iQ;
      ELSE
      SET @eMonth = 4;
      SET @eDay = @iQ - 31;
      END IF;
      SET @ChristmasDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-25')));
      SET @AdventDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))
        -(1+weekday(makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-12-04'))))));
      SET @EasterDate=STR_TO_DATE(CONCAT(@iYear,'-',@eMonth,'-',@eDay),
        '%Y-%m-%d');
      SET @PentecostDate=date_add(@EasterDate,interval 49 day);
      SET @HolyWeekDate=date_sub(@EasterDate,interval 7 day);
      SET @LentDate=date_sub(@EasterDate,interval 46 day);
      SET @EpiphanyDate=makedate(@iYear,DAYOFYEAR(CONCAT(@iYear,'-01-06')));
      IF iDate >= @ChristmasDate THEN
        SET @season_color='White';
        ELSE IF iDate >= @AdventDate THEN
          SET @season_color='Purple';
          ELSE IF iDate > @PentecostDate THEN
              SET @season_color='Green';
              ELSE IF iDate >= @EasterDate THEN
                SET @season_color='White';
                ELSE IF iDate >= @HolyWeekDate THEN
                  SET @season_color='Red';
                  ELSE IF iDate >= @LentDate THEN
                    SET @season_color='Purple';
                    ELSE IF iDate >= @EpiphanyDate THEN
                      SET @season_color='Green';
                      ELSE SET @season_color='White';
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
      RETURN @season_color;
      END ;;
      DELIMITER ;
    # setting_eucharistic_prayer
      DROP FUNCTION IF EXISTS `setting_eucharistic_prayer`;
      DELIMITER ;;
      CREATE DEFINER=`root`@`localhost`
      FUNCTION `setting_eucharistic_prayer`(iEucharisticPrayerSetting INT,
        iDateTime DATETIME, iObservance VARCHAR(40),
        iRite VARCHAR(2), iLocation VARCHAR(12), iFuneral INT, iMarriage INT,
        iBlessingRelationship INT, iBishopPresides INT)
      RETURNS varchar(12)
      DETERMINISTIC
      BEGIN
        IF (iEucharisticPrayerSetting)
          THEN IF(iEucharisticPrayerSetting=6)
            THEN RETURN('Simple');
            ELSE
              IF (iEucharisticPrayerSetting=7)
              THEN RETURN ('Solemn');
              ELSE
                IF (iEucharisticPrayerSetting=8)
                THEN RETURN ('Mozarabic');
                END IF;
              END IF;
          END IF;
        ELSE
          IF ((iObservance='Christmas Eve' and hour(iDateTime)>20)
            OR (iObservance='Easter Day' and hour(iDateTime)>8
                and hour(iDateTime)<14))
              THEN RETURN ('Mozarabic');
            ELSE
              IF (iRite='2' and iLocation='Nave'
                AND (month(iDateTime)<7
                  OR iDateTime>=makedate(year(iDateTime),
                    DAYOFYEAR(CONCAT(year(iDateTime),'-09-07'))
                      - weekday(makedate(year(iDateTime),
                    DAYOFYEAR(CONCAT(year(iDateTime),'-09-07'))))))
                AND NOT(iFuneral) AND NOT(iMarriage) AND NOT(iBlessingRelationship)
                  AND NOT(iBishopPresides)
                AND (iObservance<>'Ash Wednesday' OR hour(iDateTime)>12)
                AND (iObservance<>'Christmas Eve' OR hour(iDateTime)>17)
                AND (date(iDateTime)<>makedate(year(iDateTime),
                  DAYOFYEAR(CONCAT(year(iDateTime),'-12-25'))))
                AND (iObservance<>'Thanksgiving Day')
                AND (iObservance<>'Thanksgiving Eve'))
              THEN
                return('Solemn');
              ELSE
                return('Spoken');
              END IF;
          END IF;
        END IF;
        RETURN @eucharistic_prayer_setting;
    END ;;
    DELIMITER ;
  # setting_lords_prayer
    DROP FUNCTION IF EXISTS `setting_lords_prayer`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `setting_lords_prayer`(iLordsPrayerSetting INT,
        iDateTime DATETIME, iObservance VARCHAR(40),
        iSeason VARCHAR(30), iRite VARCHAR(2), iLocation VARCHAR(12),
        iFuneral INT, iMarriage INT, iBlessingRelationship INT,
        iBishopPresides INT)
    RETURNS int
    DETERMINISTIC
    BEGIN
      IF (iLordsPrayerSetting)
        THEN RETURN(iLordsPrayerSetting);
      ELSE IF iRite='2'
          and iLocation='Nave'
          and (iDateTime<date_july_1(iDateTime)
            or iDateTime>=date_all_saints(iDateTime))
          and NOT(iFuneral)
          and NOT(iMarriage)
          and NOT(iBlessingRelationship)
          and NOT(iBishopPresides)
          and ((iSeason)='Advent'
            or (iSeason)='Eastertide'
            or (iObservance)='Trinity Sunday'
            or (left((iObservance),9)='Christmas'
              and hour(iDateTime)>20))
          and iObservance<>'Thanksgiving Day'
          and iObservance<>'Thanksgiving Eve'
        THEN RETURN(31);
        ELSE RETURN(1);
        END IF;
      END IF;
    END ;;
    DELIMITER ;
  # setting_postcommunion_prayer
    DROP FUNCTION IF EXISTS `setting_postcommunion_prayer`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `setting_postcommunion_prayer`(iPostcommunionPrayerSetting INT,
        iSeason VARCHAR(30), iObservance VARCHAR(40), iRite VARCHAR(2),
        iFuneral INT, iMarriage INT,
        iBlessingRelationship INT, iOrdination INT,
        iUseBCP INT)
    RETURNS int
    DETERMINISTIC
    BEGIN
      IF (iPostcommunionPrayerSetting) THEN
        RETURN(iPostcommunionPrayerSetting);
        ELSE IF (iMarriage) or (iBlessingRelationship) THEN
          RETURN(940);
          ELSE IF (iOrdination) THEN
            RETURN(943);
            ELSE IF (iRite='1') THEN
              IF (iFuneral) THEN
                RETURN(936);
                ELSE RETURN(935);
                END IF;
              ELSE IF (iFuneral) THEN
                IF (iUseBCP) THEN
                  RETURN (939);
                  ELSE RETURN (951);
                  END IF;
                ELSE IF (iSeason='Advent' OR iSeason='Christmastide'
                    OR iSeason='Epiphanytide') THEN RETURN(937);
                  ELSE IF iSeason='Lent' OR iSeason='Holy Week'
                    THEN RETURN(938);
                    ELSE IF iSeason='Eastertide'
                        OR iObservance='Trinity Sunday'
                      THEN
                        IF (iUseBCP) THEN
                          RETURN(937);
                          ELSE RETURN(941);
                          END IF;
                      ELSE IF (iUseBCP) THEN
                        RETURN(938);
                        ELSE RETURN(942);
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
    END ;;
    DELIMITER ;
  # sundays_after
    DROP FUNCTION IF EXISTS `sundays_after`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `sundays_after`(iEarlyDate DATETIME, iLateDate DATETIME)
    RETURNS int
        DETERMINISTIC
    BEGIN
      SET @WEEK_DAY = (mod(week_day(iLateDate)+1,7));
      SET @SUN_DAY  = DATE_SUB(iLateDate,INTERVAL @WEEK_DAY DAY);
      RETURN DATEDIFF (iEarlyDate, @SUN_DAY);
    END ;;
    DELIMITER ;
  # text_to_boolean
    DROP FUNCTION IF EXISTS `text_to_boolean`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `text_to_boolean`(iText VARCHAR(127))
    RETURNS tinyint(1)
        DETERMINISTIC
    BEGIN
      IF LOCATE(CONCAT(';',TRIM(LOWER(iText)),';'),
          ";1;-1;t;y;yes;on;enabled;true;") != 0
        THEN RETURN (1);
        END IF;
      RETURN (0);
    END ;;
    DELIMITER ;
  # use_bcp
    DROP FUNCTION IF EXISTS `use_bcp`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `use_bcp`(iUseBCP BIT, iDateTime DATETIME)
    RETURNS varchar(8)
        DETERMINISTIC
    BEGIN
      IF (iUseBCP)
        THEN
          IF (iUseBCP=888)
            THEN RETURN 'Yes';
            ELSE RETURN 'No';
            END IF;
        ELSE
          IF (weekday(iDateTime)=2 AND hour(iDateTime)=10)
            THEN RETURN 'Yes';
            ELSE RETURN 'No';
            END IF;
        END IF;
    END ;;
    DELIMITER ;
  # use_humble_access
    DROP FUNCTION IF EXISTS `use_humble_access`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `use_humble_access`(iUseHumbleAccess INT, iSeason VARCHAR(30),
      iRite VARCHAR(2)) RETURNS varchar(4)
    DETERMINISTIC
    BEGIN
      IF iUseHumbleAccess=888
          OR (iRite='1' and iSeason<>'Eastertide') THEN
        RETURN('Yes');
        ELSE RETURN('No');
        END IF;
    END ;;
    DELIMITER ;
  # week_of
    DROP FUNCTION IF EXISTS `week_of`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `week_of`(iDate DATE)
    RETURNS date
        DETERMINISTIC
    BEGIN
      SET @WD = WEEKDAY(iDate)+1;
      IF @WD = 7 THEN SET @WD = 0; END IF ;
      RETURN iDate - INTERVAL @WD DAY;
    END ;;
    DELIMITER ;
  # week_of_observance
    DROP FUNCTION IF EXISTS `week_of_observance`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
    FUNCTION `week_of_observance`(iDate DATE)
    RETURNS char(127)
        DETERMINISTIC
    BEGIN
    SET @OBS = NULL;
    SET @EPI = 1_epiphany_offset_days(iDate);
    IF @EPI < 56 THEN SET @OBS = ('8 Epiphany') ; END IF;
    IF @EPI < 49 THEN SET @OBS = ('7 Epiphany') ; END IF;
    IF @EPI < 42 THEN SET @OBS = ('6 Epiphany') ; END IF;
    IF @EPI < 35 THEN SET @OBS = ('5 Epiphany') ; END IF;
    IF @EPI < 28 THEN SET @OBS = ('4 Epiphany') ; END IF;
    IF @EPI < 21 THEN SET @OBS = ('3 Epiphany') ; END IF;
    IF @EPI < 14 THEN SET @OBS = ('2 Epiphany') ; END IF;
    IF @EPI <  7 THEN SET @OBS = ('1 Epiphany') ; END IF;
    IF MONTH(iDate) = 1 THEN
      IF DAY(iDate) < 6 THEN SET @OBS = ('2 Christmas') ;
        IF DAY(iDate) = 6 THEN SET @OBS = ('Epiphany') ;
          END IF ;
        END IF ;
      END IF ;
    IF ( ( MONTH(iDate) = 11 ) AND ( DAY(iDate) ) ) > 26
      THEN SET @OBS = ('1 Advent'); END IF;
    CASE easter_offset_sundays (iDate)
      WHEN -7 THEN SET @OBS = ('Last Epiphany') ;
      WHEN -6 THEN SET @OBS = ('1 Lent') ;
      WHEN -5 THEN SET @OBS = ('2 Lent') ;
      WHEN -4 THEN SET @OBS = ('3 Lent') ;
      WHEN -3 THEN SET @OBS = ('4 Lent') ;
      WHEN -2 THEN SET @OBS = ('5 Lent') ;
      WHEN -1 THEN SET @OBS = ('Palm Sunday') ;
      WHEN 0 THEN SET @OBS = ('Easter Day') ;
      WHEN 1 THEN SET @OBS = ('2 Easter') ;
      WHEN 2 THEN SET @OBS = ('3 Easter') ;
      WHEN 3 THEN SET @OBS = ('4 Easter') ;
      WHEN 4 THEN SET @OBS = ('5 Easter') ;
      WHEN 5 THEN SET @OBS = ('6 Easter') ;
      WHEN 6 THEN SET @OBS = ('7 Easter') ;
      WHEN 7 THEN SET @OBS = ('Pentecost Day') ;
      WHEN 8 THEN SET @OBS = ('Trinity Sunday') ;
      WHEN 9 THEN SET @OBS = ('2 Pentecost') ;
      WHEN 10 THEN SET @OBS = ('3 Pentecost') ;
      WHEN 11 THEN SET @OBS = ('4 Pentecost') ;
      WHEN 12 THEN SET @OBS = ('5 Pentecost') ;
      WHEN 13 THEN SET @OBS = ('6 Pentecost') ;
      WHEN 14 THEN SET @OBS = ('7 Pentecost') ;
      WHEN 15 THEN SET @OBS = ('8 Pentecost') ;
      WHEN 16 THEN SET @OBS = ('9 Pentecost') ;
      WHEN 17 THEN SET @OBS = ('10 Pentecost') ;
      WHEN 18 THEN SET @OBS = ('11 Pentecost') ;
      WHEN 19 THEN SET @OBS = ('12 Pentecost') ;
      WHEN 20 THEN SET @OBS = ('13 Pentecost') ;
      WHEN 21 THEN SET @OBS = ('14 Pentecost') ;
      WHEN 22 THEN SET @OBS = ('15 Pentecost') ;
      WHEN 23 THEN SET @OBS = ('16 Pentecost') ;
      WHEN 24 THEN SET @OBS = ('17 Pentecost') ;
      WHEN 25 THEN SET @OBS = ('18 Pentecost') ;
      WHEN 26 THEN SET @OBS = ('19 Pentecost') ;
      WHEN 27 THEN SET @OBS = ('20 Pentecost') ;
      WHEN 28 THEN SET @OBS = ('21 Pentecost') ;
      WHEN 29 THEN SET @OBS = ('22 Pentecost') ;
      WHEN 30 THEN SET @OBS = ('23 Pentecost') ;
      WHEN 31 THEN SET @OBS = ('24 Pentecost') ;
      WHEN 32 THEN SET @OBS = ('25 Pentecost') ;
      WHEN 33 THEN SET @OBS = ('26 Pentecost') ;
      WHEN 34 THEN SET @OBS = ('27 Pentecost') ;
    END CASE ;
    IF MONTH(iDate) = 12 THEN
      IF DAY(iDate) > 25 THEN SET @OBS = ('1 Christmas') ;
        IF DAY(iDate) = 25 THEN SET @OBS = ('Christmas') ;
          IF DAY(iDate) > 17 THEN SET @OBS = ('4 Advent') ;
            IF DAY(iDate) > 10 THEN SET @OBS = ('3 Advent') ;
              IF DAY(iDate) >  3 THEN SET @OBS = ('2 Advent') ;
                END IF ;
              END IF ;
            END IF ;
          END IF ;
        END IF ;
      END IF ;
    IF ( ( MONTH(iDate) = 11 ) AND ( DAY(iDate) > 26 ) )
      THEN SET @OBS = ('1 Advent'); END IF;
    RETURN @OBS;
    END ;;
    DELIMITER ;
  # P_identify_weekdays
    DROP PROCEDURE IF EXISTS `P_identify_weekdays`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      PROCEDURE `P_identify_weekdays`
      (IN `i_date_begin` DATE, IN `i_date_end` DATE)
      MODIFIES SQL DATA
      BEGIN
      SET @this_date = i_date_begin;
      WHILE @this_date<=i_date_end DO
        INSERT INTO `____wd` SET obs_date=@this_date;
        SET @this_date=DATE_ADD(@this_date, INTERVAL 1 DAY);
        END WHILE;
    END ;;
    DELIMITER ;
    /*
    # Earlier version that identifies one weekday only.
    DROP PROCEDURE IF EXISTS `P_identify_weekdays`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      PROCEDURE `P_identify_weekdays`
      (IN `i_date_begin` DATE, IN `i_date_end` DATE, IN `i_wkdy` INT)
      MODIFIES SQL DATA
      BEGIN
      SET @this_date = i_date_begin;
      IF i_wkdy>=0 AND i_wkdy<=6 THEN
        SET @this_date=DATE_ADD(i_date_begin,
          INTERVAL MOD(7+i_wkdy
            -WEEKDAY(i_date_begin),7) DAY);
        WHILE @this_date<=i_date_end DO
          INSERT INTO `____wd` SET obs_date=@this_date;
          SET @this_date=DATE_ADD(@this_date, INTERVAL 7 DAY);
          END WHILE;
        END IF;
    END ;;
    DELIMITER ;
    */
  # P_log
    DROP PROCEDURE IF EXISTS `P_log`;
    DELIMITER ;;
    CREATE DEFINER=`root`@`localhost`
      PROCEDURE `P_log`
      (IN `message` varchar(255))
      MODIFIES SQL DATA
      BEGIN
        INSERT INTO `-log`
          VALUES(0,NOW(),@@system_time_zone,message);
      END ;;
    DELIMITER ;
# Populate `-current_status`, part 1 of 2
  TRUNCATE TABLE `-current_status`;
  INSERT INTO `-current_status` SET status_type="Information",
    description=CONCAT(@THIS_SCRIPT," last run: ",now(),
      " ", @@system_time_zone);
  INSERT INTO `-current_status` SET status_type="Information",
    description=CONCAT("Active configuration: ",F_config_active_set(),
      " (",F_config_text("set_name"),")");
  INSERT INTO `-current_status` SET status_type="Information",
    description=CONCAT("Start date: ",F_config_date_start());
  INSERT INTO `-current_status` SET status_type="Information",
    description=CONCAT("End date: ",F_config_date_end());
  # All other inserts should go at the end.
# Build secondary tables
  # Clean up `configuration` file
    UPDATE `configuration`
      SET `config_label`=F_multiTrim(LOWER(config_label),"\r\n\t "),
        `config_value`=F_multiTrim(LOWER(config_value),"\r\n\t ");
  # Create Lookups
    DROP TABLE IF EXISTS `__L_citations`;
      CREATE TABLE `__L_citations`
        SELECT
            citation_value cname
            , citation_id
          FROM `citations`
          ORDER BY `citation_value`;
        ALTER TABLE `__L_citations`
          ADD PRIMARY KEY (`cname`);
    DROP TABLE IF EXISTS `__L_citation_sources`;
      CREATE TABLE `__L_citation_sources`
        SELECT
            citation_source_short_name sname
            , citation_source_id
          FROM `citation_sources`
          ORDER BY `citation_source_short_name`;
        ALTER TABLE `__L_citation_sources`
          ADD PRIMARY KEY (`sname`);
    DROP TABLE IF EXISTS `__L_citation_usages`;
      CREATE TABLE `__L_citation_usages`
        SELECT
            citation_usage_name uname
            , citation_usage_id
          FROM `citation_usages`
          ORDER BY `citation_usage_name`;
        ALTER TABLE `__L_citation_usages`
          ADD PRIMARY KEY (`uname`);
    DROP TABLE IF EXISTS `__L_config_sets`;
      CREATE TABLE `__L_config_sets`
        SELECT
            config_value cname
            , config_set config_set_id
          FROM `configuration`
            WHERE LOWER(config_label)='set_name'
          ORDER BY `config_value`;
        ALTER TABLE `__L_config_sets`
          ADD PRIMARY KEY (`cname`);
    DROP TABLE IF EXISTS `__L_lectionaries`;
      CREATE TABLE `__L_lectionaries`
        SELECT
            lectionary_short_name lname
            , lectionary_id
          FROM `lectionaries`
          ORDER BY `lectionary_short_name`;
        ALTER TABLE `__L_lectionaries`
          ADD PRIMARY KEY (`lname`);
    DROP TABLE IF EXISTS `__L_lectionary_tracks`;
      CREATE TABLE `__L_lectionary_tracks`
        SELECT
            concat(l.lectionary_track_number,'/',l.lectionary_track_plan) tname
            , l.lectionary_track_id
          FROM `lectionary_tracks` l
          ORDER BY l.lectionary_track_number,l.lectionary_track_plan;
        ALTER TABLE `__L_lectionary_tracks`
          ADD PRIMARY KEY (`tname`);
    DROP TABLE IF EXISTS `__L_lectionary_years`;
      CREATE TABLE `__L_lectionary_years`
        SELECT
            lectionary_year_short_name yname
            , lectionary_year_id
          FROM `lectionary_years`
          ORDER BY `lectionary_year_short_name`;
        ALTER TABLE `__L_lectionary_years`
          ADD PRIMARY KEY (`yname`);
    DROP TABLE IF EXISTS `__L_observances`;
      CREATE TABLE `__L_observances`
        SELECT
            observance_short_name oname
            , observance_id
          FROM `observances`
          ORDER BY `observance_short_name`;
      ALTER TABLE `__L_observances`
        ADD PRIMARY KEY (`oname`);
    DROP TABLE IF EXISTS `__L_override_types`;
      CREATE TABLE `__L_override_types`
        SELECT
            override_type_name oname
            , override_type_id
          FROM `override_types`
          ORDER BY `override_type_name`;
        ALTER TABLE `__L_override_types`
          ADD PRIMARY KEY (`oname`);
    DROP TABLE IF EXISTS `__L_propers`;
      CREATE TABLE `__L_propers`
        SELECT
            proper_short_name pname
            , proper_id
          FROM `propers`
          ORDER BY `proper_short_name`;
        ALTER TABLE `__L_propers`
          ADD PRIMARY KEY (`pname`);
    DROP TABLE IF EXISTS `__L_rites`;
      CREATE TABLE `__L_rites`
        SELECT
            rite_long_name rname
            , rite_id
          FROM `rites`
          ORDER BY `rite_long_name`;
        ALTER TABLE `__L_rites`
          ADD PRIMARY KEY (`rname`);
    DROP TABLE IF EXISTS `__L_texts`;
      CREATE TABLE `__L_texts`
        SELECT
            CONCAT(c.citation_value,' (',tt.text_type_name,')') tname
            , t.text_id
          FROM `texts` t
          LEFT JOIN `citations` c
            ON c.citation_id=t.citation_id
          LEFT JOIN `text_types` tt
            ON tt.text_type_id=t.text_type_id
          WHERE c.citation_value IS NOT NULL
            AND tt.text_type_name IS NOT NULL
          ORDER BY c.citation_value, tt.text_type_name;
        ALTER TABLE `__L_texts`
          ADD PRIMARY KEY (`tname`);
    DROP TABLE IF EXISTS `__L_text_types`;
      CREATE TABLE `__L_text_types`
        SELECT
            text_type_name ttname
            , text_type_id
          FROM `text_types`
          ORDER BY `text_type_name`;
        ALTER TABLE `__L_text_types`
          ADD PRIMARY KEY (`ttname`);
  # Update comments in `configuration`
    UPDATE `configuration` c
      LEFT JOIN `citations` c2
          ON c2.citation_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",c2.citation_value)
      WHERE LOWER(config_label)='citation_id_in' OR LOWER(config_label)='citation_id_out';
    UPDATE `configuration` c
      LEFT JOIN `text_types` tt
          ON tt.text_type_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",tt.text_type_name)
      WHERE LOWER(config_label)='text_type_id_out';
    UPDATE `configuration` c
      LEFT JOIN `override_types` o
          ON o.override_type_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",o.override_type_name)
      WHERE LOWER(config_label)='override_type_id';
    UPDATE `configuration` c
      LEFT JOIN `__L_lectionary_tracks` x
          ON x.lectionary_track_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",x.tname)
      WHERE LOWER(config_label)='lectionary_track_id_in'
        OR LOWER(config_label)='lectionary_track_id_out';
    UPDATE `configuration` c
      LEFT JOIN `__L_lectionary_years` x
          ON x.lectionary_year_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",x.yname)
      WHERE LOWER(config_label)='lectionary_year_id_in'
        OR LOWER(config_label)='lectionary_year_id_out';
    UPDATE `configuration` c
      LEFT JOIN `__L_lectionaries` x
          ON x.lectionary_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",x.lname)
      WHERE LOWER(config_label)='lectionary_id_in'
        OR LOWER(config_label)='lectionary_id_out';
    UPDATE `configuration` c
      LEFT JOIN `__L_propers` x
          ON x.proper_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",x.pname)
      WHERE LOWER(config_label)='proper_id_in'
        OR LOWER(config_label)='proper_id_out';
    UPDATE `configuration` c
      LEFT JOIN `__L_citation_usages` x
          ON x.citation_usage_id=CAST(config_value AS UNSIGNED INTEGER)
        SET config_comment=CONCAT(config_value," = ",x.uname)
      WHERE LOWER(config_label)='citation_usage_id_in'
        OR LOWER(config_label)='citation_usage_id_out';
  # Create `_configuration`
    DROP TABLE IF EXISTS `_configuration`;
    CREATE TABLE `_configuration`
      SELECT
          group_id
          , group_concat(if(lower(LOWER(config_label))='active',
              config_value,NULL)) AS `active`
          , group_concat(if(LOWER(config_label)='override_type_id',
              config_value,NULL)) AS `override_type_id`
          , group_concat(if(LOWER(config_label)='citation_id_in',
              config_value,NULL)) AS `citation_id_in`
          , group_concat(if(LOWER(config_label)='begin_month',
              config_value,NULL)) AS `begin_month`
          , group_concat(if(LOWER(config_label)='begin_day',
              config_value,NULL)) AS `begin_day`
          , group_concat(if(LOWER(config_label)='cancel_recurring_same_day',
              config_value,NULL)) AS `cancel_recurring_same_day`
          , group_concat(if(LOWER(config_label)='citation_id_out',
              config_value,NULL)) AS `citation_id_out`
          , group_concat(if(LOWER(config_label)='citation_usage_in',
              config_value,NULL)) AS `citation_usage_in`
          , group_concat(if(LOWER(config_label)='drop_first_lesson',
              config_value,NULL)) AS `drop_first_lesson`
          , group_concat(if(LOWER(config_label)='drop_psalm',
              config_value,NULL)) AS `drop_psalm`
          , group_concat(if(LOWER(config_label)='drop_second_lesson',
              config_value,NULL)) AS `drop_second_lesson`
          , group_concat(if(LOWER(config_label)='drop_gospel',
              config_value,NULL)) AS `drop_gospel`
          , group_concat(if(LOWER(config_label)='end_month',
              config_value,NULL)) AS `end_month`
          , group_concat(if(LOWER(config_label)='end_day',
              config_value,NULL)) AS `end_day`
          , group_concat(if(LOWER(config_label)='eve',
              config_value,NULL)) AS `eve`
          , group_concat(if(LOWER(config_label)='holy_day_observance_method',
              config_value,NULL)) AS `holy_day_observance_method`
          , group_concat(if(LOWER(config_label)='hour_24',
              config_value,NULL)) AS `hour_24`
          , group_concat(if(LOWER(config_label)='lectionary_id_in',
              config_value,NULL)) AS `lectionary_id_in`
          , group_concat(if(LOWER(config_label)='lectionary_track_id_in',
              config_value,NULL)) AS `lectionary_track_id_in`
          , group_concat(if(LOWER(config_label)='lectionary_track_id_out',
              config_value,NULL)) AS `lectionary_track_id_out`
          , group_concat(if(LOWER(config_label)='lectionary_year_id_in',
              config_value,NULL)) AS `lectionary_year_id_in`
          , group_concat(if(LOWER(config_label)='location',
              config_value,NULL)) AS `location_id`
          , group_concat(if(LOWER(config_label)='minute',
              config_value,NULL)) AS `minute`
          , group_concat(if(LOWER(config_label)='monthly_service',
              config_value,NULL)) AS `monthly_service`
          , group_concat(if(LOWER(config_label)='proper_id',
              config_value,NULL)) AS `proper_id`
          , group_concat(if(LOWER(config_label)='proper_id_in',
              config_value,NULL)) AS `proper_id_in`
          , group_concat(if(LOWER(config_label)='rite_id',
              config_value,NULL)) AS `rite_id`
          , group_concat(if(LOWER(config_label)='rite_id_in',
              config_value,NULL)) AS `rite_id_in`
          , group_concat(if(LOWER(config_label)='service_id',
              config_value,NULL)) AS `service_id`
          , group_concat(if(LOWER(config_label)='text_type_id_out',
              config_value,NULL)) AS `text_type_id_out`
          , group_concat(if(LOWER(config_label)='week_number',
              config_value,NULL)) AS `week_number`
          , group_concat(if(LOWER(config_label)='weekday',
              config_value,NULL)) AS `weekday`
          , group_concat(if(LOWER(config_label)='weekly_service',
              config_value,NULL)) AS `weekly_service`
        FROM configuration c
        WHERE CAST(config_set AS UNSIGNED INTEGER)=F_config_active_set()
        GROUP BY group_id;
      ALTER TABLE `_configuration`
        ADD PRIMARY KEY (`group_id`);
  # Extract initial data from lectionary_contents
    # and converting citation_option_index data type
    DROP TABLE IF EXISTS `_lectionary_contents`;
    CREATE TABLE `_lectionary_contents` AS
      SELECT lectionary_content_id
        , proper_id
        , lectionary_year_id
        , lectionary_track_id
        , citation_usage_id
        , F_enum2int(citation_option_index) citation_option_index
        , rite_id
        , citation_id
        , lane_extension
        , 0 target_track
        , 0 text_id
        , 0 text_type_id
        , 0 text_length
        , 0 target_text_length
        , 0 count_of_options
        , 1 selected
      FROM `lectionary_contents`
      WHERE lectionary_id=F_config_int("lectionary_id");
    ALTER TABLE `_lectionary_contents`
      ADD PRIMARY KEY (`lectionary_content_id`);
  # Apply default track
    UPDATE `_lectionary_contents` l
      SET l.target_track=F_config_int("track_id")
    WHERE l.lectionary_track_id;
  # Apply override 1 - replace citation_id
    /*
    UPDATE `_lectionary_contents` l
    LEFT JOIN `_configuration` o
      ON o.citation_id_in=l.citation_id
    SET l.citation_id=o.citation_id_out
    WHERE F_config_boolean("apply_overrides")
      # AND o.config_set_id=F_config_active_set()
      AND o.override_type_id=1;
    */
  # Apply override 2 - replace citation by usage
    UPDATE `_lectionary_contents` l
    LEFT JOIN `_configuration` o
      ON o.lectionary_id_in=F_config_int("lectionary_id")
      AND o.proper_id_in=l.proper_id
      AND o.lectionary_year_id_in=l.lectionary_year_id
      AND o.lectionary_track_id_in=l.lectionary_track_id
      AND o.citation_usage_in=l.citation_usage_id
      AND o.rite_id_in=l.rite_id
    SET l.citation_id=o.citation_id_out
    WHERE F_config_boolean("apply_overrides")
      # AND o.config_set_id=F_config_active_set()
      AND o.override_type_id=2;
  # Apply override 3 - fix track by usage
    UPDATE `_lectionary_contents` l
    LEFT JOIN `_configuration` o
      ON o.lectionary_id_in=F_config_int("lectionary_id")
      AND o.proper_id_in=l.proper_id
      AND o.lectionary_year_id_in=l.lectionary_year_id
    SET l.target_track=o.lectionary_track_id_out
    WHERE F_config_boolean("apply_overrides")
      # AND o.config_set_id=F_config_active_set()
      AND o.override_type_id=3;
  # Calculate text_id (including California filter and Override 4)
    # F_get_text_id also adjusts for California and Override 4
    UPDATE `_lectionary_contents` l
    SET l.text_id=F_get_text_id(l.citation_id,l.citation_usage_id);
  # Calculate text_type and text_length
    UPDATE `_lectionary_contents` l
    LEFT JOIN `texts` t
      ON t.text_id=l.text_id
    SET l.text_type_id=t.text_type_id,
      l.text_length=LENGTH(t.text_content);
  # Calculate target text length
    UPDATE `_lectionary_contents` l
      LEFT JOIN (SELECT DISTINCT
          l.proper_id
          , l.lectionary_year_id
          , l.lectionary_track_id
          , l.citation_usage_id
          , l.citation_option_index
          , l.rite_id
          , IF(F_config_long_text(),max(l.text_length),min(l.text_length))
            target_text_length
        FROM _lectionary_contents l
        WHERE IF(F_config_boolean("use_lane_shortened_citations"),1,
          NOT(l.lane_extension))
        GROUP BY l.proper_id, l.lectionary_year_id,
          l.citation_usage_id, l.lectionary_track_id,
          l.citation_option_index, l.rite_id) m
          ON m.proper_id=l.proper_id
          AND m.lectionary_year_id=l.lectionary_year_id
          AND m.lectionary_track_id=l.lectionary_track_id
          AND m.citation_usage_id=l.citation_usage_id
          AND m.citation_option_index=l.citation_option_index
          AND m.rite_id=l.rite_id
        SET l.target_text_length=m.target_text_length;
  # Calculate count_of_options
    UPDATE `_lectionary_contents` l
      LEFT JOIN (SELECT DISTINCT
        l.proper_id
        , l.lectionary_year_id
        , l.lectionary_track_id
        , l.citation_usage_id
        , max(l.citation_option_index)+1 count_of_options
      FROM `_lectionary_contents` l
      GROUP BY l.proper_id, l.lectionary_year_id,
        l.citation_usage_id, l.lectionary_track_id) m
        ON m.proper_id=l.proper_id
        AND m.lectionary_year_id=l.lectionary_year_id
        AND m.lectionary_track_id=l.lectionary_track_id
        AND m.citation_usage_id=l.citation_usage_id
    SET l.count_of_options=m.count_of_options;
  # Deselect some rows because theyre an unused track
    UPDATE `_lectionary_contents` l
    SET l.selected=0
    WHERE l.text_length<>l.target_text_length
      OR (l.lectionary_track_id AND l.lectionary_track_id<>l.target_track);
  SET @section='Create (temporary) `____observances` table';
    DROP TABLE IF EXISTS `____observances`;
      CREATE TABLE `____observances`
        SELECT DISTINCT
          d.obs_date
          , d.observance_id
          , d.transferred
          , d.proper_id
          , max(l.lectionary_year_id) lectionary_year_id
          , max(l.lectionary_track_id) lectionary_track_id
        FROM `dates_of_observances` d
        LEFT JOIN `_lectionary_contents` l
          ON l.proper_id=d.proper_id AND l.selected
        WHERE
          (l.lectionary_year_id=F_Year_id_Eucharist(d.obs_date)
            OR l.lectionary_year_id=0)
          AND d.obs_date>=DATE_SUB(F_config_date_start(), INTERVAL 7 DAY)
          AND d.obs_date<=F_config_date_end()
        GROUP BY d.obs_date, d.observance_id, d.transferred, d.proper_id;
    ALTER TABLE `____observances`
      ADD PRIMARY KEY (obs_date,observance_id,proper_id);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create (temporary) `____lowest_observance_rank_per_day` table';
    DROP TABLE IF EXISTS `____lowest_observance_rank_per_day`;
      CREATE TABLE `____lowest_observance_rank_per_day`
        SELECT DISTINCT
          o.obs_date
          , min(o2.observance_rank) lowest_observance_rank
        FROM `____observances` o
        LEFT JOIN `observances` o2 ON o2.observance_id=o.observance_id
        GROUP BY o.obs_date;
    ALTER TABLE `____lowest_observance_rank_per_day`
      ADD PRIMARY KEY (obs_date);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create (temporary) `____highest_proper_sequence` table';
    DROP TABLE IF EXISTS `____highest_proper_sequence`;
      CREATE TABLE `____highest_proper_sequence`
        SELECT DISTINCT
          o.obs_date
          , o.observance_id
          , max(p.proper_sequence) highest_proper_sequence
        FROM `____observances` o
        LEFT JOIN `observances` o2 ON o2.observance_id=o.observance_id
        LEFT JOIN `____lowest_observance_rank_per_day` l
          ON l.obs_date=o.obs_date
        LEFT JOIN `propers` p ON p.proper_id=o.proper_id
        WHERE o2.observance_rank=l.lowest_observance_rank
        GROUP BY o.obs_date,o.observance_id;
    ALTER TABLE `____highest_proper_sequence`
      ADD PRIMARY KEY (obs_date,observance_id);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create (temporary) `____primary_daily_observances`';
    DROP TABLE IF EXISTS `____primary_daily_observances`;
    CREATE TABLE `____primary_daily_observances`
      SELECT
        h.obs_date
        , h.observance_id
        , p.proper_id
      FROM `____highest_proper_sequence` h
      LEFT JOIN `propers` p ON p.proper_sequence=h.highest_proper_sequence;
    ALTER TABLE `____primary_daily_observances`
      ADD PRIMARY KEY (`obs_date`);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create `_merged_lectionary` table';
    DROP TABLE IF EXISTS `_merged_lectionary`;
      CREATE TABLE `_merged_lectionary`
        SELECT DISTINCT
          o.obs_date
          , if (o.transferred,concat(o2.observance_short_name," (tr.)"),
              o2.observance_short_name) observance_name
          , if (o2.observance_short_name=p.proper_short_name,"",
              p.proper_short_name) proper_name
          , if (y.lectionary_year_long_name IS NULL,"",
              y.lectionary_year_long_name) lectionary_year_name
          , if (tr.lectionary_track_id=0,"",
              concat("Track ",tr.lectionary_track_number,"/",
                tr.lectionary_track_letter)) lectionary_track_name
          , IF (l1c.citation_value IS NULL,"",l1c.citation_value)
              first_lesson_citation
          , IF (pc.citation_value IS NULL,"",pc.citation_value)
              song_citation
          , IF (p2c.citation_value IS NULL,"",p2c.citation_value)
              alt_song_citation
          , IF (l2c.citation_value IS NULL,"",l2c.citation_value)
              second_lesson_citation
          , IF (gc.citation_value IS NULL,"",gc.citation_value)
              gospel_citation
          , IF (ppc.citation_value IS NULL,"",ppc.citation_value)
              palms_psalm_citation
          , IF (pgc.citation_value IS NULL,"",pgc.citation_value)
              palms_gospel_citation
          , p.proper_sequence
          , o.observance_id
          , o2.observance_rank
          , o.transferred
          , o.proper_id
          , o.lectionary_year_id
          , o.lectionary_track_id
          , l1l.text_id first_lesson_text_id
          , pl.text_id song_text_id
          , p2l.text_id alt_song_text_id
          , l2l.text_id second_lesson_text_id
          , gl.text_id gospel_text_id
          , ppl.text_id palms_psalm_text_id
          , pgl.text_id palms_gospel_text_id
        FROM `____observances` o
        LEFT JOIN observances o2
          ON o2.observance_id=o.observance_id
        LEFT JOIN propers p
          ON p.proper_id=o.proper_id
        LEFT JOIN lectionary_years y
          ON y.lectionary_year_id=o.lectionary_year_id
        LEFT JOIN lectionary_tracks tr
          ON tr.lectionary_track_id=o.lectionary_track_id
        LEFT JOIN `_lectionary_contents` l1l
          ON l1l.citation_usage_id=21
            AND l1l.selected
            AND l1l.proper_id=o.proper_id
            AND (l1l.lectionary_year_id=o.lectionary_year_id
              OR NOT(l1l.lectionary_year_id))
            AND l1l.citation_option_index
              =MOD(YEAR(o.obs_date),l1l.count_of_options)
          LEFT JOIN `texts` l1t
            ON l1t.text_id=l1l.text_id
              LEFT JOIN `citations` l1c
                ON l1c.citation_id=l1t.citation_id
        LEFT JOIN `_lectionary_contents` pl
          ON pl.citation_usage_id=22
            AND pl.selected
            AND pl.proper_id=o.proper_id
            AND (pl.lectionary_year_id=o.lectionary_year_id
              OR pl.lectionary_year_id=0)
            AND pl.citation_option_index
              =MOD(YEAR(o.obs_date),pl.count_of_options)
            AND pl.rite_id<>F_other_rite(F_config_int("rite_id"))
          LEFT JOIN `texts` pt
            ON pt.text_id=pl.text_id
              LEFT JOIN `citations` pc
                ON pc.citation_id=pt.citation_id
        LEFT JOIN `_lectionary_contents` l2l
          ON l2l.citation_usage_id=23
            AND l2l.selected
            AND l2l.proper_id=o.proper_id
            AND (l2l.lectionary_year_id=o.lectionary_year_id
              OR NOT(l2l.lectionary_year_id))
            AND l2l.citation_option_index
              =MOD(YEAR(o.obs_date),l2l.count_of_options)
          LEFT JOIN `texts` l2t
            ON l2t.text_id=l2l.text_id
            LEFT JOIN `citations` l2c
              ON l2c.citation_id=l2t.citation_id
        LEFT JOIN `_lectionary_contents` gl
          ON gl.citation_usage_id=25
            AND gl.selected
            AND gl.proper_id=o.proper_id
            AND (gl.lectionary_year_id=o.lectionary_year_id
              OR NOT(gl.lectionary_year_id))
            AND gl.citation_option_index
              =MOD(YEAR(o.obs_date),gl.count_of_options)
          LEFT JOIN `texts` gt
            ON gt.text_id=gl.text_id
            LEFT JOIN `citations` gc
              ON gc.citation_id=gt.citation_id
        LEFT JOIN `_lectionary_contents` ppl
          ON ppl.citation_usage_id=2
            AND ppl.selected
            AND ppl.proper_id=o.proper_id
            AND (ppl.lectionary_year_id=o.lectionary_year_id
              OR NOT(ppl.lectionary_year_id))
            AND ppl.citation_option_index
              =MOD(YEAR(o.obs_date),ppl.count_of_options)
          LEFT JOIN `texts` ppt
            ON ppt.text_id=ppl.text_id
            LEFT JOIN `citations` ppc
              ON ppc.citation_id=ppt.citation_id
        LEFT JOIN `_lectionary_contents` pgl
          ON pgl.citation_usage_id=1
            AND pgl.selected
            AND pgl.proper_id=o.proper_id
            AND (pgl.lectionary_year_id=o.lectionary_year_id
              OR NOT(pgl.lectionary_year_id))
            AND pgl.citation_option_index
              =MOD(YEAR(o.obs_date),pgl.count_of_options)
          LEFT JOIN `texts` pgt
            ON pgt.text_id=pgl.text_id
            LEFT JOIN `citations` pgc
              ON pgc.citation_id=pgt.citation_id
        LEFT JOIN `_lectionary_contents` p2l
          ON p2l.citation_usage_id=22
            AND p2l.selected
            AND p2l.proper_id=o.proper_id
            AND (p2l.lectionary_year_id=o.lectionary_year_id
              OR NOT(p2l.lectionary_year_id))
            AND p2l.citation_option_index
              =MOD(YEAR(o.obs_date),p2l.count_of_options)
            AND p2l.rite_id=F_other_rite(F_config_int("rite_id"))
          LEFT JOIN `texts` p2t
            ON p2t.text_id=p2l.text_id
              LEFT JOIN `citations` p2c
                ON p2c.citation_id=p2t.citation_id
        WHERE o.obs_date>=date_sub(F_config_date_start(), INTERVAL 7 DAY)
          AND o.obs_date<=F_config_date_end()
        ORDER BY o.obs_date,p.proper_sequence;
    ALTER TABLE `_merged_lectionary`
      ADD PRIMARY KEY(`obs_date`, `proper_sequence`);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create `_shortened_psalms` table';
    DROP TABLE IF EXISTS `_shortened_psalms`;
      CREATE TABLE `_shortened_psalms` AS
        SELECT
        p.proper_sequence
        , y.sequence lectionary_year_sequence
        , l.proper_id
        , l.lectionary_year_id
        , l.lectionary_track_id
        , F_enum2int(l.citation_option_index) citation_option_index
        , F_count_of_options(l.lectionary_year_id,l.proper_id,
              l.citation_usage_id) count_of_options
        , l.rite_id
        , l.citation_usage_id
        , l.citation_id
        , l.lectionary_content_id
        FROM `lectionary_contents` l
        LEFT JOIN `lectionary_years` y
          ON y.lectionary_year_id=l.lectionary_year_id
        LEFT JOIN `propers` p
          ON p.proper_id=l.proper_id
        #LEFT JOIN `lectionary_tracks` tr
        #  ON tr.lectionary_track_id=l.lectionary_track_id
        #LEFT JOIN `citations` c
        #  ON c.citation_id=l.citation_id
        #LEFT JOIN `citation_usages` u
        #  ON u.citation_usage_id=l.citation_usage_id
        LEFT JOIN (SELECT
          l.lectionary_year_id,
          l.proper_id,
          l.lectionary_track_id,
          l.citation_option_index,
          l.rite_id,
          min(F_citation_length(l.citation_id)) m
          FROM `lectionary_contents` l
          WHERE F_is_song(l.citation_usage_id)
          GROUP BY l.lectionary_year_id,l.proper_id,l.lectionary_track_id,
              l.citation_option_index,l.rite_id) l2
           ON l2.lectionary_year_id=l.lectionary_year_id
            AND l2.proper_id=l.proper_id
            AND l2.lectionary_track_id=l.lectionary_track_id
            AND l2.citation_option_index=l.citation_option_index
            AND l2.rite_id=l.rite_id
        WHERE F_is_song(l.citation_usage_id)
          AND F_citation_length(l.citation_id)=l2.m;
      ALTER TABLE `_shortened_psalms`
        ADD PRIMARY KEY(`lectionary_year_sequence`,`lectionary_track_id`,
          `proper_sequence`,`citation_option_index`,`rite_id`);
      INSERT INTO `_shortened_psalms` (
        SELECT proper_sequence
          , 11 lectionary_year_sequence
          , proper_id
          , 11 lectionary_year_id
          , lectionary_track_id
          , citation_option_index
          , count_of_options
          , rite_id
          , citation_usage_id
          , citation_id
          , lectionary_content_id
        FROM `_shortened_psalms`
        WHERE (proper_sequence<=10840 and lectionary_year_id=0)
          AND (proper_sequence<10400 OR proper_sequence>10450));
      INSERT INTO `_shortened_psalms` (
        SELECT proper_sequence
          , 12 lectionary_year_sequence
          , proper_id
          , 12 lectionary_year_id
          , lectionary_track_id
          , citation_option_index
          , count_of_options
          , rite_id
          , citation_usage_id
          , citation_id
          , lectionary_content_id
        FROM `_shortened_psalms`
        WHERE (proper_sequence<=10840 and lectionary_year_id=0)
          AND (proper_sequence<10400 OR proper_sequence>10450));
      INSERT INTO `_shortened_psalms` (
        SELECT proper_sequence
          , 13 lectionary_year_sequence
          , proper_id
          , 13 lectionary_year_id
          , lectionary_track_id
          , citation_option_index
          , count_of_options
          , rite_id
          , citation_usage_id
          , citation_id
          , lectionary_content_id
        FROM `_shortened_psalms`
        WHERE (proper_sequence<=10840 and lectionary_year_id=0)
          AND (proper_sequence<10400 OR proper_sequence>10450));
      DELETE FROM `_shortened_psalms`
        WHERE (proper_sequence<=10840 and lectionary_year_id=0)
          AND (proper_sequence<10400 OR proper_sequence>10450);
      DROP TABLE IF EXISTS `shortened_psalms`;
      CREATE TABLE `shortened_psalms` (
        SELECT y.lectionary_year_long_name Year
          , if (s.lectionary_track_id,
            concat(s.lectionary_track_id,"/",tr.lectionary_track_letter),
            "") Track
          , p.proper_short_name Proper
          , if (s.count_of_options>1,s.citation_option_index,"")+1 Opt
          , if (s.rite_id,s.rite_id,"") Rite
          , c.citation_value Citation
          , if (s.citation_usage_id<>22,u.citation_usage_name,"") Special
          , s.lectionary_year_sequence
          , s.proper_sequence
          , s.proper_id
          , s.lectionary_year_id
          , s.lectionary_track_id
          , s.citation_option_index
          , s.count_of_options
          , s.rite_id
          , s.citation_usage_id
          , s.citation_id
          , s.lectionary_content_id
        FROM `_shortened_psalms` s
        LEFT JOIN lectionary_years y
          ON y.lectionary_year_id=s.lectionary_year_id
        LEFT JOIN propers p
          ON p.proper_id=s.proper_id
        LEFT JOIN lectionary_tracks tr
          ON tr.lectionary_track_id=s.lectionary_track_id
        LEFT JOIN citations c
          ON c.citation_id=s.citation_id
        LEFT JOIN citation_usages u
          ON u.citation_usage_id=s.citation_usage_id
        );
      ALTER TABLE `shortened_psalms`
        ADD PRIMARY KEY (`lectionary_year_sequence`,`lectionary_track_id`,
          `proper_sequence`,`citation_usage_id`,`citation_option_index`,
          `rite_id`);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create `_merge_data_full_text` table';
    DROP TABLE IF EXISTS `_merge_data_full_text`;
      CREATE TABLE `_merge_data_full_text` AS
      SELECT
        m.obs_date
        , p.proper_short_name
        , DATE_FORMAT(m.obs_date,'%W, %M %e, %Y') date_long_format
        , IF(m.transferred,concat(o.observance_long_name," (tr.)"),
            o.observance_long_name) observance_long_name
        , F_season(m.obs_date) season
        , cl1.citation_value l1_citation
        , sl1.citation_source_long_name l1_book_full_name
        , tl1.text_content l1_fulltext
        , cp1.citation_value p1_citation
        , tp1.text_content p1_fulltext
        , cp1.citation_latin p1_latin
        , tp1.text_page p1_page
        , sp1.citation_source_long_name p1_type
        , cp1.read_aloud_text p1_verses
        , cp2.citation_value p2_citation
        , tp2.text_content p2_fulltext
        , cp2.citation_latin p2_latin
        , tp2.text_page p2_page
        , sp2.citation_source_long_name p2_type
        , cp2.read_aloud_text p2_verses
        , cl2.citation_value l2_citation
        , sl2.citation_source_long_name l2_book_full_name
        , tl2.text_content l2_fulltext
        , cg.citation_value g_citation
        , sg.citation_source_long_name g_book_full_name
        , sg.citation_source_short_name g_book_short_name
        , tg.text_content g_fulltext
        FROM `_merged_lectionary` m
        LEFT JOIN `observances` o
          ON o.observance_id=m.observance_id
        LEFT JOIN `propers` p
          ON p.proper_id=m.proper_id
        LEFT JOIN `texts` tl1
          ON tl1.text_id=m.first_lesson_text_id
          LEFT JOIN `citations` cl1
            ON cl1.citation_id=tl1.citation_id
            LEFT JOIN `citation_sources` sl1
              ON sl1.citation_source_id=cl1.citation_source_id
        LEFT JOIN `texts` tp1
          ON tp1.text_id=m.song_text_id
          LEFT JOIN `citations` cp1
            ON cp1.citation_id=tp1.citation_id
              LEFT JOIN `citation_sources` sp1
                ON sp1.citation_source_id=cp1.citation_source_id
        LEFT JOIN `texts` tp2
          ON tp2.text_id=m.alt_song_text_id
          LEFT JOIN `citations` cp2
            ON cp2.citation_id=tp2.citation_id
              LEFT JOIN `citation_sources` sp2
                ON sp2.citation_source_id=cp2.citation_source_id
        LEFT JOIN `texts` tl2
          ON tl2.text_id=m.second_lesson_text_id
          LEFT JOIN `citations` cl2
            ON cl2.citation_id=tl2.citation_id
            LEFT JOIN `citation_sources` sl2
              ON sl2.citation_source_id=cl2.citation_source_id
        LEFT JOIN `texts` tg
          ON tg.text_id=m.gospel_text_id
          LEFT JOIN `citations` cg
            ON cg.citation_id=tg.citation_id
            LEFT JOIN `citation_sources` sg
              ON sg.citation_source_id=cg.citation_source_id
        WHERE m.obs_date>=F_config_date_start()
          AND m.obs_date<=F_config_date_end();
    ALTER TABLE `_merge_data_full_text`
      ADD PRIMARY KEY (`obs_date`,`proper_short_name`);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create table `____service_templates`';
    DROP TABLE IF EXISTS `____service_templates`;
    CREATE TABLE `____service_templates`
      SELECT c.group_id
          , 'P' service_template_type
          , F_config_boolean_group(c.group_id,"active") active
          , F_config_int_group(c.group_id,"begin_month") begin_month
          , F_config_int_group(c.group_id,"begin_day") begin_day
          , F_config_int_group(c.group_id,"end_month") end_month
          , F_config_int_group(c.group_id,"end_day") end_day
          , p.proper_short_name
          , F_config_boolean_group(c.group_id,"eve") eve
          , s.service_name
          , r.rite_long_name
          , l.location_name
          , F_config_boolean_group(c.group_id,"cancel_recurring_same_day")
              cancel_recurring_same_day
          , F_config_int_group(c.group_id,"weekday") weekday
          , F_config_int_group(c.group_id,"week_number") week_number
          , F_config_boolean_group(c.group_id,"drop_first_lesson")
              drop_first_lesson
          , F_config_boolean_group(c.group_id,"drop_psalm")
              drop_psalm
          , F_config_boolean_group(c.group_id,"drop_second_lesson")
              drop_second_lesson
          , F_config_boolean_group(c.group_id,"drop_gospel")
              drop_gospel
          , F_config_int_group(c.group_id,"hour_24") hour_24
          , F_config_int_group(c.group_id,"location_id") location_id
          , F_config_int_group(c.group_id,"minute") minutes
          , F_config_int_group(c.group_id,"proper_id") proper_id
          , F_config_int_group(c.group_id,"rite_id") rite_id
          , F_config_int_group(c.group_id,"service_id") service_id
        FROM `_configuration` c
        LEFT JOIN `locations` l ON l.location_id
          =F_config_int_group(c.group_id,"location_id")
        LEFT JOIN `propers` p ON p.proper_id
          =F_config_int_group(c.group_id,"proper_id")
        LEFT JOIN `rites` r ON r.rite_id
          =F_config_int_group(c.group_id,"rite_id")
        LEFT JOIN `services` s ON s.service_id
          =F_config_int_group(c.group_id,"service_id")
        WHERE F_config_int_group(c.group_id,"proper_id")
          AND NOT(NOT(F_config_boolean_group(c.group_id,"active")));
    ALTER TABLE `____service_templates`
      ADD PRIMARY KEY (`group_id`,`service_template_type`);
    INSERT INTO `____service_templates`
      SELECT c.group_id
          , 'W' service_template_type
          , F_config_boolean_group(c.group_id,"active") active
          , F_config_int_group(c.group_id,"begin_month") begin_month
          , F_config_int_group(c.group_id,"begin_day") begin_day
          , F_config_int_group(c.group_id,"end_month") end_month
          , F_config_int_group(c.group_id,"end_day") end_day
          , p.proper_short_name
          , F_config_boolean_group(c.group_id,"eve") eve
          , s.service_name
          , r.rite_long_name
          , l.location_name
          , F_config_boolean_group(c.group_id,"cancel_recurring_same_day")
              cancel_recurring_same_day
          , F_config_int_group(c.group_id,"weekday") weekday
          , F_config_int_group(c.group_id,"week_number") week_number
          , F_config_boolean_group(c.group_id,"drop_first_lesson")
              drop_first_lesson
          , F_config_boolean_group(c.group_id,"drop_psalm")
              drop_psalm
          , F_config_boolean_group(c.group_id,"drop_second_lesson")
              drop_second_lesson
          , F_config_boolean_group(c.group_id,"drop_gospel")
              drop_gospel
          , F_config_int_group(c.group_id,"hour_24") hour_24
          , F_config_int_group(c.group_id,"location_id") location_id
          , F_config_int_group(c.group_id,"minute") minutes
          , F_config_int_group(c.group_id,"proper_id") proper_id
          , F_config_int_group(c.group_id,"rite_id") rite_id
          , F_config_int_group(c.group_id,"service_id") service_id
        FROM `_configuration` c
        LEFT JOIN `locations` l ON l.location_id
          =F_config_int_group(c.group_id,"location_id")
        LEFT JOIN `propers` p ON p.proper_id
          =F_config_int_group(c.group_id,"proper_id")
        LEFT JOIN `rites` r ON r.rite_id
          =F_config_int_group(c.group_id,"rite_id")
        LEFT JOIN `services` s ON s.service_id
          =F_config_int_group(c.group_id,"service_id")
        WHERE F_config_boolean_group(c.group_id,"weekly_service")
          AND NOT(NOT(F_config_boolean_group(c.group_id,"active")));
    REPLACE INTO `____service_templates`
      SELECT c.group_id
          , 'M' service_template_type
          , F_config_boolean_group(c.group_id,"active") active
          , F_config_int_group(c.group_id,"begin_month") begin_month
          , F_config_int_group(c.group_id,"begin_day") begin_day
          , F_config_int_group(c.group_id,"end_month") end_month
          , F_config_int_group(c.group_id,"end_day") end_day
          , p.proper_short_name
          , F_config_boolean_group(c.group_id,"eve") eve
          , s.service_name
          , r.rite_long_name
          , l.location_name
          , F_config_boolean_group(c.group_id,"cancel_recurring_same_day")
              cancel_recurring_same_day
          , F_config_int_group(c.group_id,"weekday") weekday
          , F_config_int_group(c.group_id,"week_number") week_number
          , F_config_boolean_group(c.group_id,"drop_first_lesson")
              drop_first_lesson
          , F_config_boolean_group(c.group_id,"drop_psalm")
              drop_psalm
          , F_config_boolean_group(c.group_id,"drop_second_lesson")
              drop_second_lesson
          , F_config_boolean_group(c.group_id,"drop_gospel")
              drop_gospel
          , F_config_int_group(c.group_id,"hour_24") hour_24
          , F_config_int_group(c.group_id,"location_id") location_id
          , F_config_int_group(c.group_id,"minute") minutes
          , F_config_int_group(c.group_id,"proper_id") proper_id
          , F_config_int_group(c.group_id,"rite_id") rite_id
          , F_config_int_group(c.group_id,"service_id") service_id
        FROM `_configuration` c
        LEFT JOIN `locations` l ON l.location_id
          =F_config_int_group(c.group_id,"location_id")
        LEFT JOIN `propers` p ON p.proper_id
          =F_config_int_group(c.group_id,"proper_id")
        LEFT JOIN `rites` r ON r.rite_id
          =F_config_int_group(c.group_id,"rite_id")
        LEFT JOIN `services` s ON s.service_id
          =F_config_int_group(c.group_id,"service_id")
        WHERE F_config_boolean_group(c.group_id,"monthly_service")
          AND NOT(NOT(F_config_boolean_group(c.group_id,"active")));
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create table `_service_plan`';
    DROP TABLE IF EXISTS `_service_plan`;
    CREATE TABLE `_service_plan` (
      `service_date` date NOT NULL,
      `service_time` time NOT NULL,
      `location_id` int NOT NULL,
      `location_name` varchar(64) NOT NULL,
      `weekly_or_monthly_flag` int NOT NULL DEFAULT '0',
      `observance_id` int NOT NULL,
      `observance_short_name` varchar(40),
      `observance_rank` INT DEFAULT NULL,
      `eve` int DEFAULT NULL,
      `transferred` int DEFAULT NULL,
      `proper_id` int NOT NULL,
      `service_id` INT DEFAULT NULL,
      `service_name` varchar(31) DEFAULT NULL,
      `lectionary_track_id` int,
      `rite_id` int DEFAULT NULL,
      `proper_sequence` int NOT NULL,
      `lectionary_year_id` int,
      `first_lesson_text_id` int DEFAULT '0',
      `song_text_id` int DEFAULT '0',
      `second_lesson_text_id` int DEFAULT '0',
      `gospel_text_id` int DEFAULT '0',
      `palms_psalm_text_id` int DEFAULT '0',
      `palms_gospel_text_id` int DEFAULT '0',
      PRIMARY KEY (`service_date`,`service_time`,`location_id`));
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Create bounded list of specified weekdays `____wd`';
    DROP TABLE IF EXISTS `____wd`;
    CREATE TABLE `____wd` (
      `obs_date` DATE NOT NULL PRIMARY KEY
      , `borrow_date` DATE NULL
      , `observance_id` INT NULL
      , `proper_id` INT NULL
      , `transferred` INT NULL
      , `lectionary_track_id` INT NULL
      , `proper_sequence` INT NULL
      , `lectionary_year_id` INT NULL
      , `first_lesson_text_id` INT NULL
      , `song_text_id` INT NULL
      , `alt_song_text_id` INT NULL
      , `second_lesson_text_id` INT NULL
      , `gospel_text_id` INT NULL
      , `palms_psalm_text_id` INT NULL
      , `palms_gospel_text_id` INT NULL
      );
    CALL P_identify_weekdays(F_config_date_start(),F_config_date_end());
    # CALL P_identify_weekdays(F_config_date_start(),F_config_date_end(),3);
    UPDATE `____wd` d
      SET d.borrow_date = F_most_recent_observance_date(d.obs_date);
    UPDATE `____wd` d
    LEFT JOIN `____primary_daily_observances` o ON o.obs_date=d.borrow_date
    LEFT JOIN `_merged_lectionary` m on m.obs_date=o.obs_date
      AND m.observance_id=o.observance_id
      AND m.proper_id=o.proper_id
      SET d.observance_id=o.observance_id,
        d.proper_id=o.proper_id,
        d.transferred=(d.obs_date<>d.borrow_date
          AND weekday(d.borrow_date)<>6),
        d.lectionary_track_id=m.lectionary_track_id,
        d.proper_sequence=m.proper_sequence,
        d.lectionary_year_id=m.lectionary_year_id,
        d.first_lesson_text_id=m.first_lesson_text_id,
        d.song_text_id=m.song_text_id,
        d.alt_song_text_id=m.alt_song_text_id,
        d.second_lesson_text_id=m.second_lesson_text_id,
        d.gospel_text_id=m.gospel_text_id,
        d.palms_psalm_text_id=m.palms_psalm_text_id,
        d.palms_gospel_text_id=m.palms_gospel_text_id;
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Add weekly Sunday observances';
    REPLACE INTO `_service_plan` # Marker 2022-01-13-11-22
      (SELECT
          if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        JOIN `_merged_lectionary` m
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        WHERE m.observance_id<>100 # Christmas
          AND m.observance_id<>125 # Easter
          AND F_in_date_range(m.obs_date,t.eve,
            t.begin_month,t.begin_day,t.end_month,t.end_day)
          AND t.active<>0
          AND t.service_template_type='W'
          AND t.weekday=6 # Sunday
          AND ((if(t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date))
            >= F_config_date_start())
          # AND m.proper_sequence IS NOT NULL # Label 2022-01-13-05-50
          AND weekday(m.obs_date)=6 # Sunday
          AND o.observance_rank<=4 ); # Sundays
  SET @section='Add weekly non-Sunday observances';
    REPLACE INTO `_service_plan` # Label 2022-01-13-11-39
      (SELECT
          if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        # JOIN `_merged_lectionary` m
        LEFT JOIN `____wd` m ON weekday(m.obs_date)=t.weekday
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        # WHERE m.observance_id<>100 # Christmas
        #   AND m.observance_id<>125 # Easter
        WHERE F_in_date_range(m.obs_date,t.eve,
            t.begin_month,t.begin_day,t.end_month,t.end_day)
          AND t.active<>0
          AND t.service_template_type='W'
          AND if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            >= F_config_date_start()
          AND t.weekday<>6 # non-Sunday
          AND m.proper_sequence IS NOT NULL); # Label 2020-01-13-05-51
          #AND weekday(m.obs_date)=t.weekday;
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Add monthly Sunday observances';
    REPLACE INTO `_service_plan` # Label 2022-01-13-11-40
      (SELECT
          if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        JOIN `_merged_lectionary` m
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        WHERE m.observance_id<>100 # Christmas
          AND m.observance_id<>125 # Easter
          AND F_in_date_range(m.obs_date,t.eve,
            t.begin_month,t.begin_day,t.end_month,t.end_day)
          AND t.active<>0
          AND t.service_template_type='M'
          AND t.weekday=6 # Sunday
          AND if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            >= F_config_date_start()
          AND t.week_number=ceiling(day(if (t.eve,date_sub(m.obs_date,
            interval 1 day),m.obs_date))/7)
          AND weekday(m.obs_date)=6 # Sunday
          AND o.observance_rank<=4 ); # Sundays
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Add monthly non-Sunday observances';
    REPLACE INTO `_service_plan` # Label 2022-01-13-11-42
      (SELECT
          if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        # JOIN `_merged_lectionary` m
        LEFT JOIN `____wd` m ON weekday(m.obs_date)=t.weekday
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        # WHERE m.observance_id<>100 # Christmas
        #   AND m.observance_id<>125 # Easter
        WHERE F_in_date_range(m.obs_date,t.eve,
            t.begin_month,t.begin_day,t.end_month,t.end_day)
          AND t.active<>0
          AND t.service_template_type='M'
          AND if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            >= F_config_date_start()
          AND t.week_number=ceiling(day(if (t.eve,date_sub(m.obs_date,
            interval 1 day),m.obs_date))/7)
          AND t.weekday<>6); # non-Sunday;
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Drop repeating services in conflict with proper observances';
    DROP TABLE IF EXISTS `____drop_services`;
    CREATE TABLE `____drop_services`
      SELECT DISTINCT service_date FROM (
        SELECT m.obs_date service_date
          FROM `____service_templates` t
          LEFT JOIN `_merged_lectionary` m ON m.proper_id=t.proper_id
          LEFT JOIN `propers` p ON p.proper_id=t.proper_id
          WHERE t.service_template_type='P'
            AND t.weekday IS NULL
        UNION
        SELECT
          DATE_ADD(DATE(CONCAT_WS('-',YEAR(m.obs_date),t.begin_month,t.begin_day)),
            INTERVAL MOD(7+t.weekday-WEEKDAY(DATE(CONCAT_WS('-',YEAR(m.obs_date),
              t.begin_month,t.begin_day))),7) DAY) service_date
          FROM `____service_templates` t
          JOIN `_merged_lectionary` m
          LEFT JOIN `propers` p ON p.proper_id=t.proper_id
          WHERE t.service_template_type='P'
            AND t.weekday IS NOT NULL) u;
    ALTER TABLE `____drop_services`
      ADD PRIMARY KEY (`service_date`);
    # For construction below, see https://stackoverflow.com/questions/25316143/delete-rows-in-mysql-matching-two-columns-in-another-table
    DELETE FROM `_service_plan` s
      WHERE EXISTS (SELECT 1 FROM `____drop_services` d
        WHERE d.service_date=s.service_date);
  SET @section='Add proper observances for precise dates';
    # For example, Ash Wednesday, Maundy Thursay, etc.
    REPLACE INTO `_service_plan` # Label 2022-01-13-11-44
      (SELECT
          if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        LEFT JOIN `_merged_lectionary` m ON m.proper_id=t.proper_id
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        WHERE t.active<>0
          AND t.service_template_type='P'
          AND t.weekday IS NULL
          AND t.begin_month IS NULL
          AND t.begin_day IS NULL
          AND if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            >= F_config_date_start());
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Add proper observances for specified weekdays and date ranges';
    # Example, All Saints Sunday, MLK over 2 Epiphany, etc.
    REPLACE INTO `_service_plan` # Label 2022-01-13-11-48
      (SELECT
          if (t.eve,date_sub(DATE_ADD(DATE(CONCAT_WS('-',YEAR(m.obs_date),
            t.begin_month,t.begin_day)),INTERVAL MOD(7+t.weekday
              -WEEKDAY(DATE(CONCAT_WS('-',YEAR(m.obs_date),t.begin_month,
              t.begin_day))),7) DAY), interval 1 day),
              DATE_ADD(DATE(CONCAT_WS('-',YEAR(m.obs_date),t.begin_month,
              t.begin_day)),INTERVAL MOD(7+t.weekday
              -WEEKDAY(DATE(CONCAT_WS('-',YEAR(m.obs_date),
              t.begin_month,t.begin_day))),7) DAY))
            service_date
          , maketime(t.hour_24,t.minutes,0) service_time
          , t.location_id
          , l.location_name
          , true weekly_or_monthly_flag
          , m.observance_id
          , o.observance_short_name
          , o.observance_rank
          , t.eve
          , m.transferred
          , m.proper_id
          , t.service_id
          , s.service_name
          , m.lectionary_track_id
          , t.rite_id
          , m.proper_sequence
          , m.lectionary_year_id
          , if (t.drop_first_lesson,if (t.drop_second_lesson,NULL,
              m.second_lesson_text_id),m.second_lesson_text_id)
              first_lesson_text_id
          , if (t.drop_psalm,NULL,
              if(t.rite_id=F_config_int("rite_id")
                OR m.alt_song_text_id IS NULL,
                m.song_text_id, m.alt_song_text_id)) song_text_id
          , if (t.drop_first_lesson OR t.drop_second_lesson,NULL,
              m.second_lesson_text_id) second_lesson_text_id
          , if (t.drop_gospel,NULL,m.gospel_text_id) gospel_text_id
          , m.palms_psalm_text_id
          , m.palms_gospel_text_id
        FROM `____service_templates` t
        JOIN `_merged_lectionary` m ON m.proper_id=t.proper_id
        LEFT JOIN `observances` o ON o.observance_id=m.observance_id
        LEFT JOIN `locations` l ON l.location_id=t.location_id
        LEFT JOIN `services` s ON s.service_id=t.service_id
        WHERE t.active<>0
          AND t.service_template_type='P'
          AND t.weekday IS NOT NULL
          AND if (t.eve,date_sub(m.obs_date, interval 1 day),m.obs_date)
            >= F_config_date_start());
  SET @section='Create `_service_plan_full_text` table';
    DROP TABLE IF EXISTS `_service_plan_full_text`;
      CREATE TABLE `_service_plan_full_text` AS
      SELECT
        m.service_date
        , m.service_time
        , p.proper_short_name
        , m.location_id
        , m.location_name
        , m.observance_id
        , m.observance_short_name
        , m.observance_rank
        , m.eve
        , m.transferred
        , m.proper_id
        , m.service_id
        , m.service_name
        , svc.service_full_name
        , m.lectionary_track_id
        , lt.lectionary_track_plan
        , m.rite_id
        , rts.rite_long_name
        , m.proper_sequence
        , m.lectionary_year_id
        , ly.lectionary_year_long_name
        , DATE_FORMAT(m.service_date,'%W, %M %e, %Y') date_long_format
        , IF(m.transferred,concat(o.observance_long_name," (tr.)"),
            o.observance_long_name) observance_long_name
        , F_season(m.service_date) season
        , cl1.citation_value l1_citation
        , sl1.citation_source_long_name l1_book_full_name
        , tl1.text_content l1_fulltext
        , cp1.citation_value p1_citation
        , tp1.text_content p1_fulltext
        , cp1.citation_latin p1_latin
        , tp1.text_page p1_page
        , sp1.citation_source_long_name p1_type
        , cp1.read_aloud_text p1_verses
        #, cp2.citation_value p2_citation
        , cl2.citation_value l2_citation
        , sl2.citation_source_long_name l2_book_full_name
        , tl2.text_content l2_fulltext
        , cg.citation_value g_citation
        , sg.citation_source_long_name g_book_full_name
        , sg.citation_source_short_name g_book_short_name
        , tg.text_content g_fulltext
        , cpp.citation_value pp_citation
        , tpp.text_content pp_fulltext
        , cpp.citation_latin pp_latin
        , tpp.text_page pp_page
        , spp.citation_source_long_name pp_type
        , cpp.read_aloud_text pp_verses
        , cpg.citation_value pg_citation
        , spg.citation_source_long_name pg_book_full_name
        , spg.citation_source_short_name pg_book_short_name
        , tpg.text_content pg_fulltext
        FROM `_service_plan` m
        LEFT JOIN `lectionary_tracks` lt
          ON lt.lectionary_track_id=m.lectionary_track_id
        LEFT JOIN `rites` rts
          ON rts.rite_id=m.rite_id
        LEFT JOIN `lectionary_years` ly
          ON ly.lectionary_year_id=m.lectionary_year_id
        LEFT JOIN `observances` o
          ON o.observance_id=m.observance_id
        LEFT JOIN `propers` p
          ON p.proper_id=m.proper_id
        LEFT JOIN `services` svc
          ON svc.service_id=m.service_id
        LEFT JOIN `texts` tl1
          ON tl1.text_id=m.first_lesson_text_id
          LEFT JOIN `citations` cl1
            ON cl1.citation_id=tl1.citation_id
            LEFT JOIN `citation_sources` sl1
              ON sl1.citation_source_id=cl1.citation_source_id
        LEFT JOIN `texts` tp1
          ON tp1.text_id=m.song_text_id
          LEFT JOIN `citations` cp1
            ON cp1.citation_id=tp1.citation_id
              LEFT JOIN `citation_sources` sp1
                ON sp1.citation_source_id=cp1.citation_source_id
        LEFT JOIN `texts` tl2
          ON tl2.text_id=m.second_lesson_text_id
          LEFT JOIN `citations` cl2
            ON cl2.citation_id=tl2.citation_id
            LEFT JOIN `citation_sources` sl2
              ON sl2.citation_source_id=cl2.citation_source_id
        LEFT JOIN `texts` tg
          ON tg.text_id=m.gospel_text_id
          LEFT JOIN `citations` cg
            ON cg.citation_id=tg.citation_id
            LEFT JOIN `citation_sources` sg
              ON sg.citation_source_id=cg.citation_source_id
        LEFT JOIN `texts` tpp
          ON tpp.text_id=m.palms_psalm_text_id
          LEFT JOIN `citations` cpp
            ON cpp.citation_id=tpp.citation_id
              LEFT JOIN `citation_sources` spp
                ON spp.citation_source_id=cpp.citation_source_id
        LEFT JOIN `texts` tpg
          ON tpg.text_id=m.palms_gospel_text_id
          LEFT JOIN `citations` cpg
            ON cpg.citation_id=tpg.citation_id
            LEFT JOIN `citation_sources` spg
              ON spg.citation_source_id=cpg.citation_source_id
        WHERE m.service_date>=F_config_date_start()
          AND m.service_date<=F_config_date_end();
    ALTER TABLE `_service_plan_full_text`
      ADD PRIMARY KEY (`service_date`,`service_time`,`location_id`);
    CALL P_log(CONCAT(@section," completed."));
  SET @section='Drop temporary tables';
    DROP TABLE IF EXISTS `____drop_services`;
    DROP TABLE IF EXISTS `____highest_proper_sequence`;
    DROP TABLE IF EXISTS `____lowest_observance_rank_per_day`;
    DROP TABLE IF EXISTS `____observances`;
    DROP TABLE IF EXISTS `____primary_daily_observances`;
    # DROP TABLE IF EXISTS `____service_templates`;
    DROP TABLE IF EXISTS `____wd`;
SET @section='Populate `-current_status`, part 2 of 2';
  # Checks for sequence errors in table `lectionary_contents`
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Error" status_type,
        CONCAT("Table `lectionary_contents` WHERE lectionary_content_id=",
          l.lectionary_content_id,": citation_option_index value ",
          l.citation_option_index," skips citation_option_index value ",
          F_enum2int(l.citation_option_index)-1) description
      FROM `lectionary_contents` l
      LEFT JOIN `lectionary_contents` l2
        ON l2.lectionary_id=l.lectionary_id
        AND l2.proper_id=l.proper_id
        AND l2.lectionary_track_id=l.lectionary_track_id
        AND l2.citation_usage_id=l.citation_usage_id
        AND F_enum2int(l2.citation_option_index)
          =F_enum2int(l.citation_option_index)-1
      WHERE l2.lectionary_content_id IS NULL
        AND F_enum2int(l.citation_option_index)>0
      ORDER BY l.lectionary_content_id;
  # Checks for Override Type 4 errors redirecting to non-existent texts
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Error" status_type,
        CONCAT("Table `configuration` WHERE override_type_id=",
          o.override_type_id,
          ": No `texts` record for citation_id=",o.citation_id_in,
          " and text_type_id=",o.text_type_id_out) description
      FROM `_configuration` o
      LEFT JOIN `texts` t
        ON t.citation_id=o.citation_id_in
          AND t.text_type_id=o.text_type_id_out
      WHERE t.text_id IS NULL AND o.override_type_id=4
      ORDER BY o.override_type_id;
  # Checks for citations with no corresponding text record
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Warning" status_type,
        CONCAT("Table `citations` WHERE citation_id=",c.citation_id,
          " has no corresponding text record in table texts for",
          c.citation_value) description
      FROM `citations` c
      LEFT JOIN `texts` t
        ON t.citation_id=c.citation_id
      WHERE t.text_id IS NULL
      ORDER BY c.citation_id;
  # Checks for citation records where required Latin names are missing
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Warning" status_type,
        CONCAT("Table `citations` WHERE citation_id=",c.citation_id,
          " has no Latin name specified for ",
          c.citation_value) description
      FROM `texts` t
      JOIN `text_types` tt on tt.text_type_id=t.text_type_id
      JOIN `citations` c on c.citation_id=t.citation_id
      WHERE tt.latin_name_required_in_citation
        AND c.citation_latin IS NULL OR TRIM(c.citation_latin)=''
      ORDER BY c.citation_id;
  # Checks for text records with no content in texts.text_content
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Warning" status_type,
        CONCAT("Table `texts` WHERE text_id=",t.text_id,
          " has no content in text_content field.") description
      FROM `texts` t
      WHERE t.text_content IS NULL OR TRIM(t.text_content)=''
      ORDER BY t.text_id;
  # Checks for text records where required page numbers are missing
    INSERT INTO `-current_status`
      SELECT
        NULL current_status_id,
        "Warning" status_type,
        CONCAT("Table `texts` WHERE text_id=",t.text_id,
          " has no content in text_page_number field.") description
      FROM `texts` t
      LEFT JOIN `text_types` tt on tt.text_type_id=t.text_type_id
      WHERE tt.page_numbers_required
        AND t.text_page IS NULL OR TRIM(t.text_page)=''
      ORDER BY t.text_id;
  # Wrap up
    SET @RUN_TIME = SEC_TO_TIME(TIMESTAMPDIFF(SECOND,@TIME_START,NOW()));
    INSERT INTO `-current_status` SET status_type="Information",
      description=CONCAT(@THIS_SCRIPT," run time: ",@RUN_TIME);
