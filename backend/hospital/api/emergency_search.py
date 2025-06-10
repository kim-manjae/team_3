from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import requests
import xml.etree.ElementTree as ET
from math import radians, sin, cos, sqrt, atan2
import os

router = APIRouter()

# API 설정
class APIConfig:
    BASE_URL = "http://apis.data.go.kr/B552657/ErmctInfoInqireService"
    SERVICE_KEY = os.getenv("EMERGENCY_SERVICE_KEY", "Q7Knj2bDIIEEcUa+IssDHW01vO1JbDDmNzyarPtSuPBFJ0OPxjvLgwIi+aWtIKZt/4IHjIK6cBiFvXyBXD67dw==")

# Pydantic 모델 정의
class EmergencyFacilityItem(BaseModel):
    # 필수 필드
    hpid: Optional[str] = Field(None, description="기관ID")
    dutyName: Optional[str] = Field(None, description="기관명")
    dutyAddr: Optional[str] = Field(None, description="주소")
    dutyTel1: Optional[str] = Field(None, description="대표전화1")
    dutyTel3: Optional[str] = Field(None, description="응급실전화")
    wgs84Lat: Optional[str] = Field(None, description="병원위도")
    wgs84Lon: Optional[str] = Field(None, description="병원경도")
    dgidIdName: Optional[str] = Field(None, description="진료과목")
    
    # 옵션 필드
    postCdn1: Optional[str] = Field(None, description="우편번호1")
    postCdn2: Optional[str] = Field(None, description="우편번호2")
    dutyEryn: Optional[str] = Field(None, description="응급실운영여부")
    dutyHano: Optional[str] = Field(None, description="병상수")
    dutyHayn: Optional[str] = Field(None, description="입원실가용여부")
    dutyMapimg: Optional[str] = Field(None, description="간이약도")
    
    # 응급실 관련 정보
    hvec: Optional[str] = Field(None, description="응급실")
    hvoc: Optional[str] = Field(None, description="수술실")
    hvgc: Optional[str] = Field(None, description="입원실")
    hpnicuyn: Optional[str] = Field(None, description="신생아중환자실")
    hpopyn: Optional[str] = Field(None, description="수술실")
    hperyn: Optional[str] = Field(None, description="응급실")
    hpgryn: Optional[str] = Field(None, description="입원실")
    
    # 진료시간
    dutyTime1s: Optional[str] = Field(None, description="월요일 시작시간")
    dutyTime1c: Optional[str] = Field(None, description="월요일 종료시간")
    dutyTime2s: Optional[str] = Field(None, description="화요일 시작시간")
    dutyTime2c: Optional[str] = Field(None, description="화요일 종료시간")
    dutyTime3s: Optional[str] = Field(None, description="수요일 시작시간")
    dutyTime3c: Optional[str] = Field(None, description="수요일 종료시간")
    dutyTime4s: Optional[str] = Field(None, description="목요일 시작시간")
    dutyTime4c: Optional[str] = Field(None, description="목요일 종료시간")
    dutyTime5s: Optional[str] = Field(None, description="금요일 시작시간")
    dutyTime5c: Optional[str] = Field(None, description="금요일 종료시간")
    dutyTime6s: Optional[str] = Field(None, description="토요일 시작시간")
    dutyTime6c: Optional[str] = Field(None, description="토요일 종료시간")
    dutyTime7s: Optional[str] = Field(None, description="일요일 시작시간")
    dutyTime7c: Optional[str] = Field(None, description="일요일 종료시간")
    dutyTime8s: Optional[str] = Field(None, description="공휴일 시작시간")
    dutyTime8c: Optional[str] = Field(None, description="공휴일 종료시간")
    
    # 응급실 가능 여부
    MKioskTy25: Optional[str] = Field(None, description="응급실")
    MKioskTy1: Optional[str] = Field(None, description="뇌출혈수술")
    MKioskTy2: Optional[str] = Field(None, description="뇌경색의재관류")
    MKioskTy3: Optional[str] = Field(None, description="심근경색의재관류")
    MKioskTy4: Optional[str] = Field(None, description="복부손상의수술")
    MKioskTy5: Optional[str] = Field(None, description="사지접합의수술")
    MKioskTy6: Optional[str] = Field(None, description="응급내시경")
    MKioskTy7: Optional[str] = Field(None, description="응급투석")
    MKioskTy8: Optional[str] = Field(None, description="조산산모")
    MKioskTy9: Optional[str] = Field(None, description="정신질환자")
    MKioskTy10: Optional[str] = Field(None, description="신생아")
    MKioskTy11: Optional[str] = Field(None, description="중증화상")

class EmergencyFacilityResponse(BaseModel):
    resultCode: str
    resultMsg: str
    items: List[EmergencyFacilityItem]
    numOfRows: int
    pageNo: int
    totalCount: int

class Location(BaseModel):
    latitude: float
    longitude: float
    radius: Optional[int] = 5000  # 기본 검색 반경 5km

class SearchResponse(BaseModel):
    success: bool = Field(description="성공 여부")
    message: str = Field(description="응답 메시지")
    total_count: int = Field(description="총 결과 수")
    page_no: int = Field(description="현재 페이지")
    num_of_rows: int = Field(description="페이지당 결과 수")
    items: List[EmergencyFacilityItem] = Field(description="검색 결과 목록")
    timestamp: str = Field(description="조회 시간")
    current_location: Optional[Location] = Field(None, description="현재 위치 정보")

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371  # 지구의 반경 (km)
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    distance = R * c
    return distance * 1000  # m 단위로 변환

@router.get("/api/emergency/search")
async def search_emergency_facilities(
    STAGE1: str = Query(..., description="시도 (예: 서울특별시)"),
    STAGE2: str = Query(..., description="시군구 (예: 강남구)"),
    latitude: float = Query(None, description="현재 위도"),
    longitude: float = Query(None, description="현재 경도"),
    radius: int = Query(5000, description="검색 반경(m)"),
    page_no: int = Query(1, ge=1, description="페이지 번호"),
    num_of_rows: int = Query(20, ge=1, le=100, description="페이지당 결과 수")
):
    try:
        params = {
            'serviceKey': APIConfig.SERVICE_KEY,
            'STAGE1': STAGE1,
            'STAGE2': STAGE2,
            'pageNo': page_no,
            'numOfRows': num_of_rows,
            'type': 'xml'
        }
        
        url = f"{APIConfig.BASE_URL}/getEgytBassInfoInqire"
        response = requests.get(url, params=params, timeout=30, verify=False)
        
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="API 호출 실패")
            
        root = ET.fromstring(response.text)
        items = root.findall('.//item')
        
        if not items:
            return {
                "success": True,
                "message": "검색 결과 없음",
                "total_count": 0,
                "page_no": page_no,
                "num_of_rows": num_of_rows,
                "items": [],
                "timestamp": datetime.now().isoformat(),
                "current_location": Location(latitude=latitude, longitude=longitude, radius=radius) if latitude and longitude else None
            }
            
        results = []
        for item in items:
            item_dict = {child.tag: child.text for child in item}

            # 필수 필드 체크 (기관ID, 기관명, 응급실전화 또는 대표전화, 주소, 위도, 경도, 진료과목)
            if not all([
                item_dict.get('hpid'),
                item_dict.get('dutyName'),
                (item_dict.get('dutyTel3') or item_dict.get('dutyTel1')),
                item_dict.get('dutyAddr'),
                item_dict.get('wgs84Lat'),
                item_dict.get('wgs84Lon'),
                item_dict.get('dgidIdName')
            ]):
                continue

            # 필요한 필드만 추출
            filtered_item = {
                'hpid': item_dict.get('hpid'),
                'dutyName': item_dict.get('dutyName'),
                'dutyTel': item_dict.get('dutyTel3') or item_dict.get('dutyTel1'),
                'dutyAddr': item_dict.get('dutyAddr'),
                'wgs84Lat': item_dict.get('wgs84Lat'),
                'wgs84Lon': item_dict.get('wgs84Lon'),
                'dgidIdName': item_dict.get('dgidIdName'),
            }

            # 거리 계산이 필요한 경우
            if latitude and longitude:
                try:
                    lat = float(filtered_item['wgs84Lat'])
                    lon = float(filtered_item['wgs84Lon'])
                    distance = calculate_distance(latitude, longitude, lat, lon)
                    if distance <= radius:
                        filtered_item['distance'] = distance
                        results.append(filtered_item)
                except (ValueError, TypeError):
                    continue
            else:
                results.append(filtered_item)
        
        # 거리순 정렬
        if latitude and longitude:
            results.sort(key=lambda x: x.get('distance', float('inf')))
            
        return {
            "success": True,
            "message": "검색 완료",
            "total_count": len(results),
            "page_no": page_no,
            "num_of_rows": num_of_rows,
            "items": results,
            "timestamp": datetime.now().isoformat(),
            "current_location": Location(latitude=latitude, longitude=longitude, radius=radius) if latitude and longitude else None
        }
        
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=503, detail=f"API 서버 연결 실패: {str(e)}")
    except ET.ParseError as e:
        raise HTTPException(status_code=500, detail=f"XML 파싱 실패: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 내부 오류: {str(e)}") 