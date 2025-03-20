#include <Wire.h>
#include <Adafruit_PN532.h>
#include <WiFi.h>
#include <HTTPClient.h>

// WiFi 설정
const char* ssid = "somnus";        // WiFi 이름 입력
const char* password = "smhrd0000";    // WiFi 비밀번호 입력
const char* serverUrl = "http://192.168.219.211:8001/stream";  // FastAPI 서버 주소 

// NFC 핀 설정 (ESP32-S3 I2C 핀 설정)
#define SDA_PIN 12  // 보드의 12번 핀 (GPIO 8)
#define SCL_PIN 17  // 보드의 17번 핀 (GPIO 9)

// NFC 모듈 객체 생성
Adafruit_PN532 nfc(SDA_PIN, SCL_PIN);

bool lastState = false;  // 이전 NFC 상태 저장

void setup() {
    Serial.begin(115200);
    Serial.println(" ESP32-S3 + PN532 NFC 테스트 시작!");

    // WiFi 연결
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi..."); // Wifi 연결중
    }
    Serial.println(" WiFi 연결 완료!");

    // I2C 및 NFC 모듈 초기화
    Wire.begin(SDA_PIN, SCL_PIN);
    nfc.begin();

    uint32_t versiondata = nfc.getFirmwareVersion();
    if (!versiondata) {
        Serial.println(" PN532를 찾을 수 없습니다! 연결을 확인하세요.");
        while (1);
    }

    // NFC 모듈 설정
    nfc.SAMConfig();
    Serial.println(" PN532 준비 완료!");
}

void loop() {
    uint8_t uid[7];  // NFC 태그 UID 저장
    uint8_t uidLength;
    bool currentState = false; // 초기 false로 설정

    // NFC 태그 감지 (1초 타임아웃 적용)
    if (nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 1000)) {
        Serial.println("1");  // 태그 감지됨
        currentState = true;
    } else {
        Serial.println("0");  // 태그가 감지되지 않음
        currentState = false;
    }

    // 값이 변경될 때만 서버로 전송
    if (currentState != lastState) {
        lastState = currentState;
        sendNFCData(currentState);
    }

    delay(500);  // 0.5초 간격으로 NFC 상태 체크
}

// NFC 데이터를 FastAPI 서버로 전송 (GET 방식 사용)
void sendNFCData(bool state) {
    if (WiFi.status() == WL_CONNECTED) {
        WiFiClient client;
        HTTPClient http;

        // String 객체를 사용하여 URL을 결합
        String url = String(serverUrl) + "?state=" + (state ? "true" : "false");

        http.begin(client, url);  // URL을 String 객체로 전달
        int httpResponseCode = http.GET();  // GET 요청

        Serial.print("Server response: ");
        Serial.println(httpResponseCode);
        http.end();
    } else {
        Serial.println("WiFi Disconnected!");
    }
}

