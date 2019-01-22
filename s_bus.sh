#!/bin/bash

clear

CACHE=$HOME/cache_sbus

if [ ! -d $CACHE ]
then
mkdir -p $CACHE
fi

function GET_STATION(){
curl -s "http://ws.bus.go.kr/api/rest/stationinfo/getLowStationByName?ServiceKey=0qek1QTehLrygmI%2BhlB0AAnqZhKrZ9bXdXUNgaFng9TW%2BYWSmblsO1QOt2NKiXiz7GXSF0jevRiaovPaX68vXA%3D%3D&stSrch="$1"" | xmllint --format - > $CACHE/station_info
awk -F '[<>]' '/arsId/{print $3}' $CACHE/station_info > $CACHE/station_arsId
awk -F '[<>]' '/stNm/{print $3}' $CACHE/station_info > $CACHE/station_stNm
}

function GET_BUS_LOCATION(){
curl -s "http://bus.go.kr/xmlRequest/getStationByUid.jsp?strBusNumber="$1""> $CACHE/bus_location_info
awk -F '[<>]' '/rtNm/{print $3}' $CACHE/bus_location_info > $CACHE/bus_location_rtNm
awk -F '[<>]' '/rtTpNm/{print $3}' $CACHE/bus_location_info > $CACHE/bus_location_rtTpNm
awk -F '[<>]' '/arrmsg1/{print $3}' $CACHE/bus_location_info > $CACHE/bus_location_arrmsg1
awk -F '[<>]' '/arrmsg2/{print $3}' $CACHE/bus_location_info > $CACHE/bus_location_arrmsg1
}

read -p "! 버스 정류소 검색: " STATION_NAME
echo "@ 정류소 정보 불러오는 중..."
GET_STATION "$STATION_NAME"
echo
RESULT_COUNT=1
for RESULT in $(cat $CACHE/station_stNm)
do
echo "! $RESULT_COUNT. $RESULT"
RESULT_COUNT=$((RESULT_COUNT+1))
done

read -p "! 선택: " SEL_STATION

STATION_ARSID="$(head -n $SEL_STATION $CACHE/station_arsId | tail -1)"
STATION_NAME="$(head -n $SEL_STATION $CACHE/station_stNm | tail -1)"

GET_BUS_LOCATION $STATION_ARSID
echo
RESULT_COUNT=1
for RESULT in $(cat $CACHE/bus_location_rtNm)
do
echo "============================================
= 노선명: $RESULT
= 버스종류: $(head -n $RESULT_COUNT $CACHE/bus_location_rtTpNm | tail -1)
= 첫번째 버스: $(head -n $RESULT_COUNT $CACHE/bus_location_arrmsg1 | tail -1) 도착
= 두번째 버스: $(head -n $RESULT_COUNT $CACHE/bus_location_arrmsg1 | tail -1) 도착
============================================
"
RESULT_COUNT=$((RESULT_COUNT+1))
done

rm $CACHE/*
