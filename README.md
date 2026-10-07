# 🎲 Ludo Rush

<p align="center">
  <img width="30%" alt="board" src="https://github.com/user-attachments/assets/c33bd2e6-2cde-4b22-8e22-c6ecbdfbf0ac" />
  <img width="30%" alt="game over" src="https://github.com/user-attachments/assets/e332674e-f5f2-4bef-96b7-ce4543e13eac" />
  <img width="30%" alt="waiting for player" src="https://github.com/user-attachments/assets/9ca61ca4-c6b8-45cf-83b1-304cdc4b6b9f" />
</p>

> A real-time multiplayer Ludo game built as a Telegram Mini App using Flutter, Node.js, Socket.IO, and Supabase.

## ✨ Features

### 🌍 Global Multiplayer
Join public game tables and compete against other players in real time.

### 🎮 Multiple Game Tables
Choose from different game tables and join an available match based on the selected table.

<p align="center"><img width="30%" alt="join screen" src="https://github.com/user-attachments/assets/60d95f17-eb29-4c9e-bd08-2c5c0be6b2ff" /></p>

### 👥 Play with Friends
Create a private game and invite friends to play together through Telegram.

<p align="center">
  <img width="30%" alt="play with friend mode" src="https://github.com/user-attachments/assets/664fdf92-9d66-4e39-a8a2-43c07227105c" />
  <img width="30%" alt="waiting for friends" src="https://github.com/user-attachments/assets/e83f6522-84ed-4b84-83bb-e446b742ab4b" />
</p>

### 🤖 Automatic Bot Players
If enough real players do not join a global match within a few seconds, bot players automatically fill the remaining slots.

### ⚡ Real-Time Gameplay
Game actions and player states are synchronized in real time using Socket.IO and WebSocket communication.

### 🔐 Telegram Authentication
The application authenticates Telegram users using Telegram Mini App initData validation on the server.

### ⏱️ Turn Timer & Move Validation
The backend manages player turns, turn timeouts, dice rolls, token movement, and game-action validation.

### 🔄 Connection Recovery
Players can reconnect after a temporary connection loss and recover the current game state.

### 💬 In-Game Stickers
Send stickers during gameplay to interact and communicate with other players.

<p align="center"><img width="50%" alt="stickers" src="https://github.com/user-attachments/assets/c975c8e4-2cf3-4f7c-895b-e7f5ae52deae" /></p>

### 🎁 Daily Rewards
Players can claim daily rewards and earn coins for their account.

<p align="center"><img width="30%" alt="daily rewards" src="https://github.com/user-attachments/assets/b40e89bb-cd51-4ae0-8a9a-509fef0f0061" /></p>

### 🏆 Leaderboard
Compete with other players and track rankings based on collected coins.

<p align="center"><img width="30%" alt="leader board" src="https://github.com/user-attachments/assets/a823a22f-1fd1-4b86-af0a-94f1cde13c0a" /></p>

### 👤 Telegram Profile Integration
Display Telegram profile information, including the player's profile picture and username, directly in the game.

<p align="center"><img width="30%" alt="profile" src="https://github.com/user-attachments/assets/68ba730a-d498-4adb-b2a1-6077457c05d7" /></p>

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Flutter Web
- Telegram Mini Apps
- Riverpod
- Riverpod Generator

### Backend & Real-Time
- Node.js
- Express.js
- Socket.IO
- WebSocket
- REST/HTTP APIs

### Telegram Integration
- Telegram Mini App initData Authentication
- Telegram Bot
- Telegraf
- Telegram Webhooks

### Database & Storage
- Supabase
- Supabase Storage

### Architecture & Development
- Clean Architecture
- Object-Oriented Programming (OOP)
- Server-Side Game Logic
- Real-Time State Synchronization
- Git / GitHub

### Deployment
- Render

## 🏗️ Architecture

Ludo Rush uses a client-server architecture with server-authoritative game logic.

```text
┌──────────────────────────────┐
│      Flutter Frontend        │
│                              │
│  Telegram Mini App           │
│  Riverpod                    │
│  Game UI & Client State      │
└──────────────┬───────────────┘
               │
               │ Socket.IO / WebSocket
               ▼
┌──────────────────────────────┐
│       Node.js Backend        │
│                              │
│  Express.js                  │
│  Authentication              │
│  Matchmaking                 │
│  Game Logic                  │
│  Bot Players                 │
│  Turn Management             │
│  Move Validation             │
│  State Management            │
│  Connection Recovery         │
└──────────────┬───────────────┘
               │
               │ Database / Storage
               ▼
┌──────────────────────────────┐
│          Supabase            │
│                              │
│  Player Data                 │
│  Game Data                   │
│  Persistent State            │
│  Avatar Storage              │
└──────────────────────────────┘
```

## 🧠 Backend & Real-Time Design

The game follows a server-authoritative model: important gameplay decisions and validation are handled on the backend rather than trusted solely to the client.

The backend is responsible for:
- Matchmaking and game-table management
- Player authentication
- Turn management and timeouts
- Dice roll processing
- Token movement validation
- Bot player behavior
- Game-state synchronization
- Reconnection and state recovery
- Persistent player and game data

## 🤖 Bot Players

Global matches automatically add bot players when real players do not join within the waiting period.

Bot gameplay includes:
- Automated dice rolls
- Valid move detection
- Token selection
- Turn execution
- Randomized action delays

## 📱 Telegram Mini App

Ludo Rush runs directly inside Telegram as a Mini App, without requiring a separate mobile installation.

### Telegram Bot

**Bot:** [@LudoRushBot](https://t.me/LudoRushBot)

## 🚀 Project Highlights

- Built and deployed a real-time multiplayer game as a Telegram Mini App.
- Implemented server-authoritative game logic with Node.js and Socket.IO.
- Built real-time matchmaking for global and private games.
- Implemented automatic bot players for unavailable player slots.
- Implemented Telegram initData authentication and Telegram user integration.
- Used Riverpod and Riverpod Generator for Flutter state management.
- Implemented turn timers, move validation, and game-state synchronization.
- Implemented connection recovery after temporary network interruptions.
- Integrated Supabase for persistent player/game data and avatar storage.
- Built and maintained the application for production deployment on Render.
