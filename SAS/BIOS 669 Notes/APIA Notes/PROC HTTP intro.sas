FILENAME carrbor1 TEMP;

PROC HTTP
    URL="https://api.sunrise-sunset.org/json?lat=35.9101&lng=-79.0753"
    METHOD="GET"
    OUT=carrbor1;
RUN;

LIBNAME sunrise JSON FILEREF=carrbor1;
