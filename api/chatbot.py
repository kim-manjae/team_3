from fastapi import APIRouter, FastAPI, HTTPException
from pydantic import BaseModel
import google.generativeai as genai
import os
from dotenv import load_dotenv

router = APIRouter()
# 환경 변수 로드
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

if not GOOGLE_API_KEY:
    raise Exception("GOOGLE_API_KEY 환경 변수가 설정되지 않았습니다.")

# Google Generative AI 구성
genai.configure(api_key=GOOGLE_API_KEY)

# GenerativeModel 초기화
model = genai.GenerativeModel(
    'gemini-2.5-flash-preview-05-20',
    #AI 모델의 역할 부여 
    system_instruction="""
        너의 이름은 "에이닥"이야 너는 환자들의 증상에 맞춰 설명을 해주고, 그에 따라 알맞은 병원과 약국들을 추천해주는 역할이야. 
        항상 친절하고 이해하기 쉽게 설명해줘.
    """
)

# 요청 모델 정의
class ChatRequest(BaseModel):
    prompt: str

@router.post("/chat/")
async def chat(request: ChatRequest):
    try:
        # 사용자 프롬프트 추출
        user_prompt = request.prompt

        # 모델을 사용하여 응답 생성
        response = model.generate_content(
            user_prompt,
            generation_config=genai.types.GenerationConfig(
                candidate_count=1,
                temperature=0.7
            )
        )

        # 응답 처리
        if response.candidates and response.candidates[0].content.parts:
            generated_text = ''.join([part.text for part in response.candidates[0].content.parts])
        else:
            raise HTTPException(status_code=500, detail="유효한 응답 내용을 찾을 수 없습니다.")

        return {"reply": generated_text.strip()}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 내부 오류: {str(e)}")