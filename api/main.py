from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from medical_search import router as medical_search_router
from medical_detail import router as medical_detail_router
from emergency_search import router as emergency_search_router
from chatbot import router as chatbot_router
from dbmain import router as dbmain_router

app = FastAPI(
    title="병원/약국 찾기 API",
    description="공공데이터포털 의료기관 정보를 제공하는 API 서비스",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(medical_search_router)
app.include_router(medical_detail_router)
app.include_router(emergency_search_router)
app.include_router(chatbot_router)
app.include_router(dbmain_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)