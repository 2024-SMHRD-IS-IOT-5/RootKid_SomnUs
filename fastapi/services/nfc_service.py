class NFCService:
    def __init__(self):
        self.nfc_state = None # True / False 상태 저장
        
    def update_nfc_state(self, new_state: bool):
        # nfc 상태가 변경될 때만 업데이트
        if self.nfc_state != new_state:
            self.nfc_state = new_state
            print(f"NFC 상태 변경: {self.nfc_state}")
            return True
        return False
    
nfc_service = NFCService()