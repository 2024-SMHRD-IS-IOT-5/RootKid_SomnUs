#include <Arduino.h>
#include <WiFi.h>
#include "Audio.h"

// 핀 설정
#define I2S_BCLK 5
#define I2S_WCLK 6
#define I2S_DOUT 7
#define LM386_POWER 48
#define PCM5102A_XMT 10

// WiFi 설정
const char* ssid = "AICAM_301B";
const char* password = "a123456789";
const char* streamURL = "http://192.168.219.211:8001/stream"; 

Audio audio;

void setup() {
    Serial.begin(115200);
    
    // 전원 설정
    pinMode(LM386_POWER, OUTPUT);
    digitalWrite(LM386_POWER, HIGH);
    
    pinMode(PCM5102A_XMT, OUTPUT);
    digitalWrite(PCM5102A_XMT, HIGH);
    
    // WiFi 연결
    WiFi.begin(ssid, password);
    WiFi.setAutoReconnect(true);
    WiFi.persistent(true);

    Serial.print("WiFi 연결 중...");
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nWiFi 연결됨");

    // 오디오 설정
    audio.setPinout(I2S_BCLK, I2S_WCLK, I2S_DOUT);
    audio.setVolume(18);
    audio.setTone(0, 0, 0);
    audio.setBufsize(20480, 1024);  // 적절한 버퍼 크기 설정

    // 스트리밍 시작
    audio.connecttohost(streamURL);
    Serial.println("스트리밍 시작");
}

void loop() {
    audio.loop();
    
    if(WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi 재연결 중...");
        WiFi.reconnect();
    }
}

// 오디오 정보 콜백
void audio_info(const char *info) {
    Serial.print("info: ");
    Serial.println(info);
}

