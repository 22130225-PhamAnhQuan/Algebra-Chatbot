from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()


class ChatMessage(BaseModel):
    role: str  
    content: str


class ChatRequest(BaseModel):
    math_problem: str  
    math_solution: str  
    new_question: str  
    chat_history: List[ChatMessage]  


@router.post("/api/chat-context")
async def chat_with_context(request: ChatRequest):
    try:
        # 1. Tạo System Prompt ép AI giữ vai trò gia sư toán và dựa vào ngữ cảnh
        system_prompt = (
            f"Bạn là một gia sư toán học THCS. Hãy giúp học sinh hiểu rõ bài toán sau.\n"
            f"Đề bài: {request.math_problem}\n"
            f"Lời giải đã có: {request.math_solution}\n"
            f"Hãy trả lời câu hỏi mới của học sinh ngắn gọn, dễ hiểu, bám sát bài toán trên."
        )

        # 2. Xây dựng mảng tin nhắn gửi cho Phi-3 Mini
        messages = [{"role": "system", "content": system_prompt}]

        # Thêm lịch sử chat cũ vào (nếu có)
        for msg in request.chat_history:
            messages.append({"role": msg.role, "content": msg.content})

        # Thêm câu hỏi mới nhất của học sinh vào cuối mảng
        messages.append({"role": "user", "content": request.new_question})

        # 3. Gọi mô hình Phi-3 Mini 
        import requests
        response = requests.post(
            "http://localhost:11434/api/chat",
            json={"model": "phi3", "messages": messages, "stream": False}
        )

        ai_response = response.json()["message"]["content"]
        return {"status": "success", "reply": ai_response}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))