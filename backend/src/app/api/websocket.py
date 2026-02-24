from fastapi import WebSocket, WebSocketDisconnect
from typing import List, Dict
import json

class ConnectionManager:
    def __init__(self):
        # room_id -> {user_id: WebSocket}
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str, user_id: str):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        self.active_connections[room_id][user_id] = websocket

    def disconnect(self, websocket: WebSocket, room_id: str, user_id: str):
        if room_id in self.active_connections:
            if user_id in self.active_connections[room_id]:
                del self.active_connections[room_id][user_id]
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]

    async def send_personal_message(self, message: dict, websocket: WebSocket):
        await websocket.send_json(message)

    async def send_to_user(self, message: dict, room_id: str, user_id: str):
        if room_id in self.active_connections and user_id in self.active_connections[room_id]:
            await self.active_connections[room_id][user_id].send_json(message)

    async def broadcast(self, message: dict, room_id: str):
        if room_id in self.active_connections:
            for user_id, connection in self.active_connections[room_id].items():
                await connection.send_json(message)

manager = ConnectionManager()
