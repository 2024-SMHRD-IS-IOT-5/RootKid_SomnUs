#include <Arduino.h>
#include <WiFi.h>
#include <Wire.h>
#include <Adafruit_PN532.h>
#include <HTTPClient.h>
#include "Audio.h"

// 핀 설정
#define I2S_BCLK 5
#define I2S_WCLK 6
#define I2S_DOUT 7
#define LM386_POWER 48
#define PCM5102A_XMT 10

// NFC 핀 설정 (ESP32-S3 I2C 핀)
#define SDA_PIN 12
#define SCL_PIN 17

// WiFi 설정
const char* ssid = "somnus";        // WiFi 이름 입력
const char* password = "smhrd0000";    // WiFi 비밀번호 입력
const char* serverUrl = "http://192.168.219.211:8001/stream";  // FastAPI 서버 주소 

// 오디오 및 NFC 객체
Audio audio;
Adafruit_PN532 nfc(SDA_PIN, SCL_PIN);

// NFC 상태 추적
bool lastState = false;

void setup() {
    Serial.begin(115200);
    Serial.println("ESP32-S3 오디오 스트리밍 + PN532 NFC 테스트");
    
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
    
    // I2C 및 NFC 모듈 초기화
    Wire.begin(SDA_PIN, SCL_PIN);
    nfc.begin();
    
    uint32_t versiondata = nfc.getFirmwareVersion();
    if (!versiondata) {
        Serial.println("PN532를 찾을 수 없습니다! 연결을 확인하세요.");
        while (1); // NFC 모듈을 찾지 못하면 진행하지 않음
    }
    
    // NFC 설정
    nfc.SAMConfig();
    Serial.println("PN532 준비 완료!");
    
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
    // 오디오 처리
    audio.loop();
    
    // WiFi 연결 확인 및 재연결
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi 재연결 중...");
        WiFi.reconnect();
    }
    
    // NFC 태그 감지 (1초 타임아웃 적용)
    uint8_t uid[7];  // UID 저장 버퍼
    uint8_t uidLength;
    bool currentState = false;
    
    if (nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 1000)) {
        Serial.println("1");  // 태그 감지됨
        currentState = true;
        
        // UID 출력 (선택사항)
        Serial.print("UID: ");
        for (uint8_t i = 0; i < uidLength; i++) {
            Serial.print(" 0x"); Serial.print(uid[i], HEX);
        }
        Serial.println();
    } else {
        Serial.println("0");  // 태그가 감지되지 않음
        currentState = false;
    }
    
    // 상태가 변경될 때만 서버로 전송
    if (currentState != lastState) {
        lastState = currentState;
        sendNFCData(currentState);
    }
    
    delay(1000);  // 1초 간격으로 NFC 상태 체크
}

// 오디오 정보 콜백
void audio_info(const char *info) {
    Serial.print("오디오 정보: ");
    Serial.println(info);
}

// NFC 데이터를 FastAPI 서버로 전송
void sendNFCData(bool state) {
    if (WiFi.status() == WL_CONNECTED) {
        WiFiClient client;
        HTTPClient http;
        
        // URL과 상태 매개변수 결합
        String url = String(serverUrl) + "/stream?state=" + (state ? "true" : "false");
        
        http.begin(client, url);
        int httpResponseCode = http.GET();
        
        Serial.print("서버 응답: ");
        Serial.println(httpResponseCode);
        http.end();
    } else {
        Serial.println("WiFi 연결 끊김!");
    }
}