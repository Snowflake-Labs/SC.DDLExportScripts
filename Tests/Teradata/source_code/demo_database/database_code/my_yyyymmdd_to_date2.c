/*
   my_yyyymmdd_to_date2.c
   Teradata User Defined Function (UDF)
   Calling
   -------
   my_yyyymmdd_to_date2(date_str);
   SELECT my_yyyymmdd_to_date2('20130423') AS ValidDate;
   Parameters
   ----------
   date_str
        Character string containing date to be validated
   UDF Compilation
   ---------------
   REPLACE FUNCTION my_yyyymmdd_to_date2
        (
            InputDate VARCHAR(8)
        )
    RETURNS DATE
    LANGUAGE C
    NO SQL
    DETERMINISTIC
    PARAMETER STYLE SQL
    EXTERNAL NAME 'CS!my_yyyymmdd_to_date2!./my_yyyymmdd_to_date2.c'
    ;
*/
/*	Must define SQL_TEXT before including "sqltypes_td	"*/
/*	Must define SQL_TEXT before including "sqltypes_td	"*/
#define SQL_TEXT Latin_Text
#include "sqltypes_td.h"
#include "stdio.h"
#include "string.h"
#define IsNull -1
#define IsNotNull 0
#define NoSqlError "00000"
#define YYYYMMDD_LENGTH 8
#define ERR_RC 99
void my_yyyymmdd_to_date2
(
     VARCHAR_LATIN      *InputDateString
     ,DATE              *result
     ,int               *inputDateStringIsNull
     ,int               *resultIsNull
     ,char              sqlstate[6]
     ,SQL_TEXT          extname[129]
     ,SQL_TEXT          specificname[129]
     ,SQL_TEXT          error_message[257]
)
{
     char input_integer[30];
     int  year_yyyy;
     int  month_mm;
     int  day_dd;
     char day_char[3];
     char month_char[3];
     char year_char[5];
     int  in_len,i;
     /* Return Nulls on Null Input */
     if ((*inputDateStringIsNull == IsNull))
     {
          strcpy(sqlstate, "22018") ;
          strcpy((char *) error_message, "Null value not allowed.") ;
          *resultIsNull = IsNull;
          return;
     }
     in_len = strlen(InputDateString);
     if ( in_len != YYYYMMDD_LENGTH )
     {
          *result = ( 1 * 10000 ) + ( 12 * 100) + 1;
          *resultIsNull = IsNull;
          strcpy((char *) sqlstate, "01H01");
          strcpy((char *) error_message,
          "InputDateString is of wrong length, must be in YYYYMMDD format");
          return;
     }
     if ( in_len != YYYYMMDD_LENGTH )
     {
          *result = ( 1 * 10000 ) + ( 12 * 100) + 2;
          return;
     }
     strcpy(input_integer , (char *) InputDateString);
     for (i = 0; i<in_len; i++)
     {
          if (input_integer[i] < '0' || input_integer[i] > '9')
          {
               *result = ( 1 * 10000 ) + ( 1 * 100) + 3;
               return;
          }
          else
          {
              input_integer[i] = tolower(input_integer[i]);
          }
     }
     sprintf(year_char,"%c%c%c%c",input_integer[0],input_integer[1],input_integer[2],
     input_integer[3]);
     sprintf(month_char,"%c%c",input_integer[4],input_integer[5]);
     sprintf(day_char,"%c%c",input_integer[6],input_integer[7]);
     year_yyyy	= atoi(year_char);
     month_mm	= atoi(month_char);
     day_dd		= atoi(day_char);
     /*	Format output_date in internal Teradata format ((YEAR - 1900) * 10000 ) +
     (MONTH * 100) + DAY	*/
     *result = (( year_yyyy - 1900 ) * 10000 ) + ( month_mm * 100) + day_dd;
}