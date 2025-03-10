### report_repository
### api/report 에서 리포트 생성 매서드 진행 후, db에 저장하기 위해 이 파일을 호출
### db 는 db/databse 에 db로서 함수로 저장되어있음.
### collection은 reports
### 데이터 형태는 db.보고서.insertOne({ content: [Array<stirng>] startDate: new “Date”, endDate: “Date”,});
### 일간 : .Today (Date)   주간 : n월m주차 (String)    월간 : n월(String)
### 각각 단위기간, 맨트, 시작일자, 종료일자. endDate는 일간일 경우엔 null로 처리.
