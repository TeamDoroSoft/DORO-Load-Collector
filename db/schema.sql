-- DORO Load Backend 승인 스키마 (14개 Table)
-- 근거: DORO_Load_Backend_API_Specification_v1.0.md, DORO_Load_Backend_Application_Implementation_Guide_v1.0.md
-- 이 파일은 애플리케이션이 자동 실행하지 않는 검토·수동 적용 전용 산출물이다 (spring.jpa.hibernate.ddl-auto=validate).
-- Character Set: utf8mb4, 시간: UTC 저장, 좌표: SRID 4326 (longitude-latitude axis-order)
-- schema/schema-current.sql(V1~V9 적용된 실제 DB 상태) 기준으로 동기화됨.

SET NAMES utf8mb4;

-- 1. 사업자
CREATE TABLE operator (
    operator_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    operator_code   VARCHAR(50)  NOT NULL,
    legal_name      VARCHAR(255) NOT NULL,
    PRIMARY KEY (operator_id),
    UNIQUE KEY uk_operator_code (operator_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 차량 제조사 Master
CREATE TABLE brand (
    brand_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (brand_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 표준 커넥터 Master (원자 커넥터 코드; 복합 코드는 charger_connector/vehicle_connector에서 N행으로 분해)
CREATE TABLE connector_type (
    connector_code  VARCHAR(50)  NOT NULL,
    connector_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 외부 원천 Metadata
CREATE TABLE data_source (
    source_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    source_name  VARCHAR(255) NOT NULL,
    source_type  VARCHAR(50)  NULL,
    endpoint     VARCHAR(500) NULL,
    PRIMARY KEY (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 충전 네트워크 (Operator 1:N, 연산자당 네트워크 1개)
CREATE TABLE charging_network (
    network_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    operator_id   BIGINT UNSIGNED NOT NULL,
    network_name  VARCHAR(255) NOT NULL,
    PRIMARY KEY (network_id),
    UNIQUE KEY uk_network_operator (operator_id),
    CONSTRAINT fk_network_operator FOREIGN KEY (operator_id) REFERENCES operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. 차량 Model (Brand 1:N)
CREATE TABLE vehicle_model (
    model_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand_id    BIGINT UNSIGNED NOT NULL,
    model_name  VARCHAR(200) NOT NULL,
    PRIMARY KEY (model_id),
    CONSTRAINT fk_model_brand FOREIGN KEY (brand_id) REFERENCES brand (brand_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. 충전소 (공간 조회 기준 Column 포함)
CREATE TABLE station (
    station_id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    network_id        BIGINT UNSIGNED NOT NULL,
    station_name      VARCHAR(255) NOT NULL,
    address           VARCHAR(500) NOT NULL,
    station_type      VARCHAR(50)  NULL,
    is_closed         BOOLEAN      NOT NULL DEFAULT FALSE,
    location          POINT NOT NULL SRID 4326,
    operating_hours   VARCHAR(255) NULL,
    updated_at        DATETIME NULL,
    last_collected_at DATETIME NULL,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (station_id),
    CONSTRAINT fk_station_network FOREIGN KEY (network_id) REFERENCES charging_network (network_id),
    SPATIAL INDEX spx_station_location (location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. 사업자별 유효기간 요금 (현재 공개 API는 조회하지 않음, 향후 정산 기능 대비 스키마만 유지)
CREATE TABLE tariff (
    tariff_id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    network_id      BIGINT UNSIGNED NOT NULL,
    customer_type   VARCHAR(50) NULL,
    speed_class     VARCHAR(50) NULL,
    price_per_kwh   DECIMAL(10,2) NULL,
    effective_from  DATE NULL,
    effective_to    DATE NULL,
    PRIMARY KEY (tariff_id),
    CONSTRAINT fk_tariff_network FOREIGN KEY (network_id) REFERENCES charging_network (network_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. 차량 Trim (Model 1:N)
CREATE TABLE vehicle_trim (
     vehicle_trim_id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    model_id              BIGINT UNSIGNED NOT NULL,
    trim_name              VARCHAR(200)    NOT NULL,
    vehicle_type           VARCHAR(50)         NULL,       -- 차량 유형(예: 중형 SUV)
    is_current_sale         BOOLEAN             NULL,       -- 현재 국내 판매 중 여부
    battery_kwh            DECIMAL(6,2)        NULL,       -- 배터리 용량(kWh)
    normal_range_km        INT                 NULL,       -- 상온 주행가능거리(km)
    cold_range_km           INT                 NULL,       -- 저온 복합 주행거리(km)
    max_ac_kw              DECIMAL(5,2)        NULL,       -- 차량 최대 AC 충전 입력(kW)
    max_dc_kw               DECIMAL(5,2)        NULL,       -- 차량 최대 DC 충전 입력(kW)
    efficiency_km_per_kwh   DECIMAL(4,2)        NULL,       -- 공인 전비(km/kWh)
    fast_charge_minutes     INT                 NULL,       -- 급속 충전 소요 시간(분)
    data_source              VARCHAR(500)        NULL,       -- 스펙 출처
    surveyed_at              DATE                NULL,       -- 조사 기준일
    note                     VARCHAR(500)        NULL,       -- 비고(트림 분리 사유, 저온값 산출 방식 등)
    PRIMARY KEY (vehicle_trim_id),
    CONSTRAINT fk_trim_model FOREIGN KEY (model_id) REFERENCES vehicle_model (model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. 충전기 (Station 1:N)
CREATE TABLE charger (
    charger_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    station_id            BIGINT UNSIGNED NOT NULL,
    external_charger_id   VARCHAR(100) NULL,
    charger_name          VARCHAR(100) NULL,
    charger_type          VARCHAR(50)  NULL,
    max_power_kw          DECIMAL(6,2) NULL,
    PRIMARY KEY (charger_id),
    CONSTRAINT fk_charger_station FOREIGN KEY (station_id) REFERENCES station (station_id),
    UNIQUE KEY uk_charger_external_id (station_id, external_charger_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. 충전소 ↔ 원천 매칭 (N:M 해소, 복합 PK)
CREATE TABLE station_source_link (
    station_id          BIGINT UNSIGNED NOT NULL,
    source_id           BIGINT UNSIGNED NOT NULL,
    source_station_id   VARCHAR(100) NULL,
    match_method        VARCHAR(50)  NULL,
    match_score         DECIMAL(5,4) NULL,
    PRIMARY KEY (station_id, source_id),
    CONSTRAINT fk_link_station FOREIGN KEY (station_id) REFERENCES station (station_id),
    CONSTRAINT fk_link_source FOREIGN KEY (source_id) REFERENCES data_source (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. 차량 Trim ↔ 지원 커넥터 (N:M 해소, 복합 PK)
CREATE TABLE vehicle_connector (
    vehicle_trim_id  BIGINT UNSIGNED NOT NULL,
    connector_code   VARCHAR(50) NOT NULL,
    charge_mode      VARCHAR(10) NULL,
    is_standard      BOOLEAN     NULL,
    note             VARCHAR(255) NULL,
    PRIMARY KEY (vehicle_trim_id, connector_code),
    CONSTRAINT fk_vconn_trim FOREIGN KEY (vehicle_trim_id) REFERENCES vehicle_trim (vehicle_trim_id),
    CONSTRAINT fk_vconn_connector_type FOREIGN KEY (connector_code) REFERENCES connector_type (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. 충전기 ↔ 제공 커넥터 (N:M 해소, 복합 PK)
CREATE TABLE charger_connector (
    charger_id       BIGINT UNSIGNED NOT NULL,
    connector_code   VARCHAR(50) NOT NULL,
    PRIMARY KEY (charger_id, connector_code),
    CONSTRAINT fk_cconn_charger FOREIGN KEY (charger_id) REFERENCES charger (charger_id),
    CONSTRAINT fk_cconn_connector_type FOREIGN KEY (connector_code) REFERENCES connector_type (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. 충전기 상태 이력 (Append-only, 덮어쓰기 금지)
CREATE TABLE charger_status_history (
    status_id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    charger_id           BIGINT UNSIGNED NOT NULL,
    status               VARCHAR(50) NOT NULL,
    source_updated_at    DATETIME NULL,
    collected_at         DATETIME NULL,
    PRIMARY KEY (status_id),
    CONSTRAINT fk_status_charger FOREIGN KEY (charger_id) REFERENCES charger (charger_id),
    KEY idx_status_charger_collected (charger_id, collected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 최신 충전기 상태 View: source_updated_at → collected_at → status_id 순으로 최신 판정
CREATE VIEW v_charger_latest_status AS
SELECT charger_id, status, source_updated_at, collected_at
FROM (
    SELECT
        h.*,
        ROW_NUMBER() OVER (
            PARTITION BY h.charger_id
            ORDER BY
                h.source_updated_at DESC,
                h.collected_at DESC,
                h.status_id DESC
        ) AS rn
    FROM charger_status_history h
) ranked
WHERE ranked.rn = 1;
