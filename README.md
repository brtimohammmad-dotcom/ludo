# 🎲 Ludo Rush
<p align="center">
  <img width="30%" alt="board" src="https://github.com/user-attachments/assets/c33bd2e6-2cde-4b22-8e22-c6ecbdfbf0ac" />
  <img width="30%" alt="game over" src="https://github.com/user-attachments/assets/e332674e-f5f2-4bef-96b7-ce4543e13eac" />
  <img width="30%" alt="waiting for player" src="https://github.com/user-attachments/assets/9ca61ca4-c6b8-45cf-83b1-304cdc4b6b9f" />
</p>

## ✨ Features

### 🌍 Global Multiplayer
Join public game tables and compete against other players in real time.

### 🎮 Multiple Game Tables
Choose from different game tables and join an available match based on the selected table.

<p align="center">
  <img width="30%" alt="join screen" src="https://github.com/user-attachments/assets/60d95f17-eb29-4c9e-bd08-2c5c0be6b2ff" />
</p>

### 👥 Play with Friends
Create a private game and invite friends to play together through Telegram.
<p align="center">
  <img width="30%" alt="play with friend mode" src="https://github.com/user-attachments/assets/664fdf92-9d66-4e39-a8a2-43c07227105c"/>
    <img width="30%" alt="waiting for friends" src="https://github.com/user-attachments/assets/e83f6522-84ed-4b84-83bb-e446b742ab4b"/>
</p>

### 🤖 Automatic Bot Players
If enough real players do not join a global match within a few seconds, bot players automatically fill the remaining slots.

### ⚡ Real-Time Gameplay
Game actions and player states are synchronized in real time using Socket.IO and WebSocket communication.

### 💬 In-Game Stickers
Send stickers during gameplay to interact and communicate with other players.

<p align="center">
  <img width="50%" alt="stickers" src="https://github.com/user-attachments/assets/c975c8e4-2cf3-4f7c-895b-e7f5ae52deae" />
</p>

### 🎁 Daily Rewards
Players can claim daily rewards and earn coins for their account.

<p align="center">
  <img width="30%" alt="daily rewards" src="https://github.com/user-attachments/assets/b40e89bb-cd51-4ae0-8a9a-509fef0f0061"/>
</p>

### 🏆 Leaderboard
Compete with other players and track rankings based on collected coins.

<p align="center">
  <img width="30%" alt="leader board" src="https://github.com/user-attachments/assets/a823a22f-1fd1-4b86-af0a-94f1cde13c0a"/>
</p>

### 👤 Telegram Profile Integration
Display Telegram profile information, including the player's profile picture and username, directly in the game.
<p align="center">
  <img width="30%" alt="profile" src="https://github.com/user-attachments/assets/68ba730a-d498-4adb-b2a1-6077457c05d7"/>
</p>

### 🔄 Game State Recovery
Recover the current game state when a player reconnects after a temporary connection loss.

<p align="center">
  <img width="30%" alt="reconnecting" src="https://github.com/user-attachments/assets/05d6cb9f-578d-4a29-aec4-5b708a8e7077"/>
    <img width="30%" alt="disconnected" src="https://github.com/user-attachments/assets/00e81989-b0fe-4245-bd46-7eac2606ccfb"/>

</p>

## 🏗️ Architecture

Ludo Rush uses a client-server architecture designed for real-time multiplayer gameplay.

```text
┌─────────────────────────┐
│    Flutter Frontend     │
│      Telegram Mini App  │
└────────────┬────────────┘
             │
             │ Socket.IO
             │ WebSocket
             ▼
┌─────────────────────────┐
│      Node.js Backend    │
│                         │
│  • Game Logic           │
│  • Matchmaking          │
│  • Bot Players          │
│  • Authentication       │
│  • Game State Management│
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│         Supabase        │
│                         │
│  • Player Data          │
│  • Game Data            │
│  • Persistent Data      │
└─────────────────────────┘
```
## 📱 Telegram Mini App
Ludo Rush is built as a Telegram Mini App, allowing players to launch and play the game directly inside Telegram without installing a separate application.
### 🤖 Telegram Bot

**Bot:** [@LudoRushBot](https://t.me/LudoRushBot)


