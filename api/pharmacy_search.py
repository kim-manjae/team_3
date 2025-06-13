from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import requests
import xml.etree.ElementTree as ET
import os
import threading
import time
from dotenv import load_dotenv

router = APIRouter()
load_dotenv(dotenv_path="key.env")

class APIConfig:
    BASE_URL = "http://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyFullDown"
    SERVICE_KEY = os.getenv("PHARMACY_SERVICE_KEY")

class PharmacyFacility(BaseModel):
    hpid: Optional[str] = Field(None, description="기관ID")
    dutyName: Optional[str] = Field(None, description="기관명")
    dutyAddr: Optional[str] = Field(None, description="주소")
    dutyTel1: Optional[str] = Field(None, description="대표전화")
    wgs84Lat: Optional[str] = Field(None, description="위도")
    wgs84Lon: Optional[str] = Field(None, description="경도")
    postCdn1: Optional[str] = Field(None, description="우편번호1")
    postCdn2: Optional[str] = Field(None, description="우편번호2")
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

PHARMACY_CACHE = []
PHARMACY_CACHE_LAST_UPDATED = None

def fetch_and_cache_pharmacies():
    global PHARMACY_CACHE, PHARMACY_CACHE_LAST_UPDATED
    try:
        params = {
            'serviceKey': APIConfig.SERVICE_KEY,
            'type': 'xml',
            'pageNo': 1,
            'numOfRows': 500,
        }
        url = APIConfig.BASE_URL
        response = requests.get(url, params=params, timeout=120, verify=False)
        if response.status_code == 200:
            root = ET.fromstring(response.text)
            items = root.findall('.//item')
            cache = []
            for item in items:
                item_dict = {child.tag: child.text for child in item}
                cache.append(item_dict)
            PHARMACY_CACHE = cache
            PHARMACY_CACHE_LAST_UPDATED = datetime.now()
            print(f"[약국 전체 데이터 캐싱 완료] {len(PHARMACY_CACHE)}건")
        else:
            print(f"[약국 전체 데이터 캐싱 실패] {response.status_code}: {response.text}")
    except Exception as e:
        print(f"[약국 전체 데이터 캐싱 예외] {e}")

def schedule_pharmacy_cache_refresh(interval_sec=86400):
    def refresh():
        while True:
            fetch_and_cache_pharmacies()
            time.sleep(interval_sec)
    threading.Thread(target=refresh, daemon=True).start()

schedule_pharmacy_cache_refresh()

@router.get("/api/pharmacy/all")
async def get_all_pharmacy_facilities():
    pharmacies = PHARMACY_CACHE
    processed = []
    for p in pharmacies:
        item = dict(p)
        item['distance'] = None
        item['is_open'] = None
        item['today_open_status'] = None
        if 'dutyName' in item:
            item['dutyname'] = item['dutyName']
        if 'dutyAddr' in item:
            item['dutyaddr'] = item['dutyAddr']
        if 'dutyTel1' in item:
            item['dutytel1'] = item['dutyTel1']
        if 'wgs84Lat' in item:
            item['wgs84lat'] = item['wgs84Lat']
        if 'wgs84Lon' in item:
            item['wgs84lon'] = item['wgs84Lon']
        if 'postCdn1' in item:
            item['postcdn1'] = item['postCdn1']
        if 'postCdn2' in item:
            item['postcdn2'] = item['postCdn2']
        processed.append(item)
    return {
        "success": True,
        "items": processed,
        "total_count": len(processed),
        "timestamp": datetime.now().isoformat()
    } 