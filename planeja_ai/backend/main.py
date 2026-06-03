from fastapi import FastAPI

app = FastAPI(
    title="Planeja.AI API",
    description="Backend API for Planeja.AI personal finance assistant",
    version="1.0.0"
)

@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "Planeja.AI Backend API",
        "docs_url": "/docs"
    }
