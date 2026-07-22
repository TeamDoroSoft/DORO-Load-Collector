-- =============================================================================
-- DORO Load - 차량 스펙 시드 데이터 (Flyway V11)
-- MySQL 8.0 / InnoDB / utf8mb4
-- 팀 직접 조사 PDF(브랜드차량조사) 기반. 공공 API에 차량 스펙이 없어 수동 시드.
-- FK 의존성 순서: brand -> vehicle_model -> vehicle_trim -> vehicle_connector
-- V4 스타일 그대로 모든 INSERT를 INSERT ... SELECT ... WHERE NOT EXISTS 로
-- 자연키 기준 idempotent 처리(brand_name / (brand,model) / (model,trim) /
-- (trim, connector_code)). 재적용해도 중복 생성되지 않는다.
-- brand 29개(국내 공식 판매 이력 브랜드 전체), vehicle_trim 203행.
-- 토요타/포드/피아트는 이번 조사에서 판매 모델이 최종 삭제돼 brand만 시드하고
-- vehicle_model/vehicle_trim은 없다.
-- =============================================================================

-- 1) BRAND (29개)
INSERT INTO brand (brand_name)
SELECT 'BMW'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = 'BMW');

INSERT INTO brand (brand_name)
SELECT 'BYD'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = 'BYD');

INSERT INTO brand (brand_name)
SELECT 'DS'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = 'DS');

INSERT INTO brand (brand_name)
SELECT 'KGM'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = 'KGM');

INSERT INTO brand (brand_name)
SELECT 'MINI'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = 'MINI');

INSERT INTO brand (brand_name)
SELECT '기아'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '기아');

INSERT INTO brand (brand_name)
SELECT '닛산'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '닛산');

INSERT INTO brand (brand_name)
SELECT '렉서스'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '렉서스');

INSERT INTO brand (brand_name)
SELECT '로터스'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '로터스');

INSERT INTO brand (brand_name)
SELECT '롤스로이스'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '롤스로이스');

INSERT INTO brand (brand_name)
SELECT '르노코리아'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '르노코리아');

INSERT INTO brand (brand_name)
SELECT '마세라티'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '마세라티');

INSERT INTO brand (brand_name)
SELECT '메르세데스-벤츠'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '메르세데스-벤츠');

INSERT INTO brand (brand_name)
SELECT '볼보'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '볼보');

INSERT INTO brand (brand_name)
SELECT '쉐보레'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '쉐보레');

INSERT INTO brand (brand_name)
SELECT '아우디'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '아우디');

INSERT INTO brand (brand_name)
SELECT '재규어'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '재규어');

INSERT INTO brand (brand_name)
SELECT '제네시스'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '제네시스');

INSERT INTO brand (brand_name)
SELECT '지프'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '지프');

INSERT INTO brand (brand_name)
SELECT '캐딜락'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '캐딜락');

INSERT INTO brand (brand_name)
SELECT '테슬라'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '테슬라');

INSERT INTO brand (brand_name)
SELECT '토요타'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '토요타');

INSERT INTO brand (brand_name)
SELECT '포드'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '포드');

INSERT INTO brand (brand_name)
SELECT '포르쉐'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '포르쉐');

INSERT INTO brand (brand_name)
SELECT '폭스바겐'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '폭스바겐');

INSERT INTO brand (brand_name)
SELECT '폴스타'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '폴스타');

INSERT INTO brand (brand_name)
SELECT '푸조'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '푸조');

INSERT INTO brand (brand_name)
SELECT '피아트'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '피아트');

INSERT INTO brand (brand_name)
SELECT '현대'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE brand_name = '현대');

-- 2) VEHICLE_MODEL
INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'i3'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'i3');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'i4'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'i4');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'i5'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'i5');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'i7'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'i7');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'iX'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'iX');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'iX1'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'iX1');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'iX2'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'iX2');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'iX3'
FROM brand b
WHERE b.brand_name = 'BMW'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BMW' AND vm.model_name = 'iX3');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'ATTO 3'
FROM brand b
WHERE b.brand_name = 'BYD'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BYD' AND vm.model_name = 'ATTO 3');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'DOLPHIN'
FROM brand b
WHERE b.brand_name = 'BYD'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'SEAL'
FROM brand b
WHERE b.brand_name = 'BYD'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BYD' AND vm.model_name = 'SEAL');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'SEALION 7'
FROM brand b
WHERE b.brand_name = 'BYD'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'BYD' AND vm.model_name = 'SEALION 7');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'DS 3 E-TENSE'
FROM brand b
WHERE b.brand_name = 'DS'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '무쏘 EV'
FROM brand b
WHERE b.brand_name = 'KGM'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'KGM' AND vm.model_name = '무쏘 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '코란도 이모션'
FROM brand b
WHERE b.brand_name = 'KGM'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'KGM' AND vm.model_name = '코란도 이모션');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '토레스 EVX'
FROM brand b
WHERE b.brand_name = 'KGM'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'KGM' AND vm.model_name = '토레스 EVX');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'MINI Electric'
FROM brand b
WHERE b.brand_name = 'MINI'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'MINI' AND vm.model_name = 'MINI Electric');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '뉴 MINI 쿠퍼 일렉트릭'
FROM brand b
WHERE b.brand_name = 'MINI'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '에이스맨'
FROM brand b
WHERE b.brand_name = 'MINI'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'MINI' AND vm.model_name = '에이스맨');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '컨트리맨 일렉트릭'
FROM brand b
WHERE b.brand_name = 'MINI'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EV3'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'EV3');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EV4'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'EV4');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EV5'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'EV5');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EV6'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'EV6');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EV9'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'EV9');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'PV5'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = 'PV5');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '니로 EV 1세대'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '니로 EV 1세대');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '더 기아 레이 EV'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '디 올 뉴 니로 EV'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '레이 EV 1세대'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '레이 EV 1세대');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '봉고 III EV'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '봉고 III EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '쏘울 EV'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '쏘울 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '쏘울 부스터 EV'
FROM brand b
WHERE b.brand_name = '기아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '리프'
FROM brand b
WHERE b.brand_name = '닛산'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '닛산' AND vm.model_name = '리프');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'RZ'
FROM brand b
WHERE b.brand_name = '렉서스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '렉서스' AND vm.model_name = 'RZ');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'UX 300e'
FROM brand b
WHERE b.brand_name = '렉서스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '렉서스' AND vm.model_name = 'UX 300e');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '에메야'
FROM brand b
WHERE b.brand_name = '로터스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '로터스' AND vm.model_name = '에메야');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '엘레트라'
FROM brand b
WHERE b.brand_name = '로터스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '로터스' AND vm.model_name = '엘레트라');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '스펙터'
FROM brand b
WHERE b.brand_name = '롤스로이스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '롤스로이스' AND vm.model_name = '스펙터');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'SM3 Z.E.'
FROM brand b
WHERE b.brand_name = '르노코리아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '세닉 E-Tech 일렉트릭'
FROM brand b
WHERE b.brand_name = '르노코리아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm.model_name = '세닉 E-Tech 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '조에(ZOE)'
FROM brand b
WHERE b.brand_name = '르노코리아'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '그란투리스모 폴고레'
FROM brand b
WHERE b.brand_name = '마세라티'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '마세라티' AND vm.model_name = '그란투리스모 폴고레');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '그레칼레 폴고레'
FROM brand b
WHERE b.brand_name = '마세라티'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '마세라티' AND vm.model_name = '그레칼레 폴고레');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQA'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQB'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQB');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQC'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQC');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQE'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQE SUV'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQS'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EQS SUV'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'G 580 with EQ Technology'
FROM brand b
WHERE b.brand_name = '메르세데스-벤츠'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm.model_name = 'G 580 with EQ Technology');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'C40 Recharge / EC40'
FROM brand b
WHERE b.brand_name = '볼보'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'EX30'
FROM brand b
WHERE b.brand_name = '볼보'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '볼보' AND vm.model_name = 'EX30');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'XC40 Recharge / EX40'
FROM brand b
WHERE b.brand_name = '볼보'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '볼트 EUV'
FROM brand b
WHERE b.brand_name = '쉐보레'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm.model_name = '볼트 EUV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '볼트 EV'
FROM brand b
WHERE b.brand_name = '쉐보레'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm.model_name = '볼트 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '스파크 EV'
FROM brand b
WHERE b.brand_name = '쉐보레'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm.model_name = '스파크 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Q4 Sportback e-tron'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Q4 e-tron'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Q6 e-tron'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Q8 e-tron'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'e-tron 50/55 quattro'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'e-tron GT'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'e-tron GT');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'e-tron Sportback'
FROM brand b
WHERE b.brand_name = '아우디'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'I-PACE'
FROM brand b
WHERE b.brand_name = '재규어'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '재규어' AND vm.model_name = 'I-PACE');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Electrified G80'
FROM brand b
WHERE b.brand_name = '제네시스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '제네시스' AND vm.model_name = 'Electrified G80');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Electrified GV70'
FROM brand b
WHERE b.brand_name = '제네시스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '제네시스' AND vm.model_name = 'Electrified GV70');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'GV60'
FROM brand b
WHERE b.brand_name = '제네시스'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '제네시스' AND vm.model_name = 'GV60');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '어벤저 EV'
FROM brand b
WHERE b.brand_name = '지프'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '지프' AND vm.model_name = '어벤저 EV');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '리릭'
FROM brand b
WHERE b.brand_name = '캐딜락'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '캐딜락' AND vm.model_name = '리릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Model 3'
FROM brand b
WHERE b.brand_name = '테슬라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '테슬라' AND vm.model_name = 'Model 3');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Model S'
FROM brand b
WHERE b.brand_name = '테슬라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '테슬라' AND vm.model_name = 'Model S');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Model X'
FROM brand b
WHERE b.brand_name = '테슬라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '테슬라' AND vm.model_name = 'Model X');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Model Y'
FROM brand b
WHERE b.brand_name = '테슬라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '테슬라' AND vm.model_name = 'Model Y');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '마칸 일렉트릭'
FROM brand b
WHERE b.brand_name = '포르쉐'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '타이칸'
FROM brand b
WHERE b.brand_name = '포르쉐'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm.model_name = '타이칸');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'ID.4'
FROM brand b
WHERE b.brand_name = '폭스바겐'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '폭스바겐' AND vm.model_name = 'ID.4');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'ID.5'
FROM brand b
WHERE b.brand_name = '폭스바겐'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '폭스바겐' AND vm.model_name = 'ID.5');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Polestar 2'
FROM brand b
WHERE b.brand_name = '폴스타'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '폴스타' AND vm.model_name = 'Polestar 2');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'Polestar 4'
FROM brand b
WHERE b.brand_name = '폴스타'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '폴스타' AND vm.model_name = 'Polestar 4');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'e-2008'
FROM brand b
WHERE b.brand_name = '푸조'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '푸조' AND vm.model_name = 'e-2008');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'e-208'
FROM brand b
WHERE b.brand_name = '푸조'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '푸조' AND vm.model_name = 'e-208');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, 'ST1'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = 'ST1');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '디 올 뉴 코나 일렉트릭'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '아이오닉 5'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '아이오닉 5');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '아이오닉 6'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '아이오닉 6');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '아이오닉 9'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '아이오닉 9');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '아이오닉 일렉트릭'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '캐스퍼 일렉트릭'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭');

INSERT INTO vehicle_model (brand_id, model_name)
SELECT b.brand_id, '코나 일렉트릭 1세대'
FROM brand b
WHERE b.brand_name = '현대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_model vm JOIN brand b2 ON b2.brand_id = vm.brand_id
    WHERE b2.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대');

-- 3) VEHICLE_TRIM (203행)
INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '120Ah', '소형 해치백', FALSE, 42.2, 248, 179, 11, 50, 5.4, 42, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i3' AND vt.trim_name = '120Ah');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '60Ah', '소형 해치백', FALSE, 42.2, 248, 179, 11, 50, 5.4, 42, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i3' AND vt.trim_name = '60Ah');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '94Ah', '소형 해치백', FALSE, 42.2, 248, 179, 11, 50, 5.4, 42, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i3' AND vt.trim_name = '94Ah');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'i3s', '소형 해치백', FALSE, 42.2, 248, 179, 11, 50, 5.4, 42, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i3' AND vt.trim_name = 'i3s');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M50', '중형 패스트백', TRUE, 83.9, 511, 368, 11, 205, 4.6, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i4/bmwi4-gran-coupe.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i4' AND vt.trim_name = 'M50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M60', '중형 패스트백', TRUE, 83.9, 511, 368, 11, 205, 4.6, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i4/bmwi4-gran-coupe.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i4' AND vt.trim_name = 'M60');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'eDrive40', '중형 패스트백', TRUE, 83.9, 511, 376, 11, 205, 4.6, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i4/bmwi4-gran-coupe.html / 환경부 공개 저온성능비율 73.6%와 국내 상온 511km 기준 환산(약 376km)', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온 복합 주행거리 반영 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i4' AND vt.trim_name = 'eDrive40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive40', '중형 패스트백', TRUE, 83.9, 511, 368, 11, 205, 4.6, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i4/bmwi4-gran-coupe.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i4' AND vt.trim_name = 'xDrive40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M60', '준대형 세단', TRUE, 84.3, 459, 330, 11, 205, 4.5, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i5/bmwi5-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i5' AND vt.trim_name = 'M60');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'eDrive40', '준대형 세단', TRUE, 84.3, 459, 330, 11, 205, 4.5, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i5/bmwi5-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i5' AND vt.trim_name = 'eDrive40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive40', '준대형 세단', TRUE, 84.3, 459, 330, 11, 205, 4.5, 30, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i5/bmwi5-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i5' AND vt.trim_name = 'xDrive40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M70', '대형 세단', TRUE, 105.7, 455, 328, 11, 195, 3.7, 34, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i7/bmwi7-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i7' AND vt.trim_name = 'M70');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'eDrive50', '대형 세단', TRUE, 105.7, 455, 328, 11, 195, 3.7, 34, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i7/bmwi7-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i7' AND vt.trim_name = 'eDrive50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive60', '대형 세단', TRUE, 105.7, 455, 328, 11, 195, 3.7, 34, 'https://www.bmw.co.kr/ko/all-models/bmw-i/i7/bmwi7-sedan.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'i7' AND vt.trim_name = 'xDrive60');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M60', '대형 SUV', TRUE, 111.5, 447, 322, 11, 195, 3.7, 35, 'https://www.bmw.co.kr/ko/all-models/bmw-i/bmwix/bmw-ix.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX' AND vt.trim_name = 'M60');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive40', '대형 SUV', TRUE, 111.5, 447, 322, 11, 195, 3.7, 35, 'https://www.bmw.co.kr/ko/all-models/bmw-i/bmwix/bmw-ix.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX' AND vt.trim_name = 'xDrive40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive50', '대형 SUV', TRUE, 111.5, 447, 322, 11, 195, 3.7, 35, 'https://www.bmw.co.kr/ko/all-models/bmw-i/bmwix/bmw-ix.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX' AND vt.trim_name = 'xDrive50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'eDrive20', '준중형 SUV', TRUE, 66.5, 310, 223, 11, 130, 4.6, 29, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX1' AND vt.trim_name = 'eDrive20');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive30', '준중형 SUV', TRUE, 66.5, 310, 223, 11, 130, 4.6, 29, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX1' AND vt.trim_name = 'xDrive30');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'eDrive20', '준중형 쿠페 SUV', TRUE, 66.5, 350, 252, 11, 130, 4.7, 29, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX2' AND vt.trim_name = 'eDrive20');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'xDrive30', '준중형 쿠페 SUV', TRUE, 66.5, 350, 252, 11, 130, 4.7, 29, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX2' AND vt.trim_name = 'xDrive30');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'M Sport', '중형 SUV', FALSE, 80, 344, 248, 11, 150, 4.1, 34, 'https://www.bmw.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BMW' AND vm2.model_name = 'iX3' AND vt.trim_name = 'M Sport');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Plus', '준중형 SUV', TRUE, 60.5, 321, 225, 7, 88, 4.7, 37, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 30→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'ATTO 3' AND vt.trim_name = 'Plus');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Standard', '준중형 SUV', TRUE, 60.5, 321, 225, 7, 88, 4.7, 37, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 30→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'ATTO 3' AND vt.trim_name = 'Standard');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'DOLPHIN', '소형 해치백', TRUE, 49.92, 307, 215, 7, 65, 5.5, 30, 'https://www.bydauto.kr/car/byd-dolphin / https://www.bydauto.kr/static/file/BYD_DOLPHIN_Catalog.pdf / https://www.sedaily.com/article/20050777', '2026-07-17', '국내 공식 가격 2,450만원·견적/시승 가능. 저온값은 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 국내 실제 판매 확인: 2026년 4월 800대, 6월 2,747대 판매 보도 / 급속 SOC 기준: 30→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'DOLPHIN Active', '소형 해치백', TRUE, 60.48, 354, 248, 7, 88, 5.1, 30, 'https://www.bydauto.kr/car/byd-dolphin / https://www.bydauto.kr/static/file/BYD_DOLPHIN_Catalog.pdf / https://www.sedaily.com/article/20050777', '2026-07-17', '국내 공식 가격 2,920만원·견적/시승 가능. 저온값은 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 국내 실제 판매 확인: 2026년 4월 800대, 6월 2,747대 판매 보도 / 급속 SOC 기준: 30→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN Active');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AWD', '중형 세단', TRUE, 82.6, 520, 364, 11, 150, 4.8, 37, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'SEAL' AND vt.trim_name = 'AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RWD', '중형 세단', TRUE, 82.6, 520, 364, 11, 150, 4.8, 37, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색 기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'SEAL' AND vt.trim_name = 'RWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AWD', '중형 SUV', TRUE, 91.3, 450, 315, 11, 230, 4.2, 24, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://topictree.co.kr/automobiles/new-car/byd-sealion-7-deliveries-begin-for-korean-customers', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 국내 실제 고객 인도 및 판매 확인 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'SEALION 7' AND vt.trim_name = 'AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RWD', '중형 SUV', TRUE, 91.3, 450, 315, 11, 230, 4.2, 24, 'https://www.bydauto.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://topictree.co.kr/automobiles/new-car/byd-sealion-7-deliveries-begin-for-korean-customers', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 국내 실제 고객 인도 및 판매 확인 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'BYD' AND vm2.model_name = 'SEALION 7' AND vt.trim_name = 'RWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Opera', '소형 SUV', FALSE, 54, 260, 177, 11, 100, 4.4, 30, 'https://www.dsautomobiles.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'DS' AND vm2.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Opera');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Rivoli', '소형 SUV', FALSE, 54, 260, 177, 11, 100, 4.4, 30, 'https://www.dsautomobiles.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'DS' AND vm2.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Rivoli');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '2WD', '전기 픽업트럭', TRUE, 80.6, 400, 280, 11, 150, 3.8, 36, 'https://www.kg-mobility.com / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '무쏘 EV' AND vt.trim_name = '2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '4WD', '전기 픽업트럭', TRUE, 80.6, 400, 280, 11, 150, 3.8, 36, 'https://www.kg-mobility.com / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '국내 인증 세부값 확인 필요 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '무쏘 EV' AND vt.trim_name = '4WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E3', '준중형 SUV', FALSE, 61.5, 307, 215, 11, 100, 4.9, 33, 'https://www.kg-mobility.com / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '코란도 이모션' AND vt.trim_name = 'E3');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E5', '준중형 SUV', FALSE, 61.5, 307, 215, 11, 100, 4.9, 33, 'https://www.kg-mobility.com / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색기반 추정값(상온×70%), 공식 인증값 아님 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '코란도 이모션' AND vt.trim_name = 'E5');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E5', '중형 SUV', TRUE, 73.4, 433, 304, 11, 120, 5, 37, 'https://www.kg-mobility.com/kr/vehicle/torres-evx / 조선비즈 2024-10-25: 토레스 EVX 20인치 저온비율 70.1%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '토레스 EVX' AND vt.trim_name = 'E5');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E7', '중형 SUV', TRUE, 73.4, 433, 304, 11, 120, 5, 37, 'https://www.kg-mobility.com/kr/vehicle/torres-evx / 조선비즈 2024-10-25: 토레스 EVX 20인치 저온비율 70.1%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'KGM' AND vm2.model_name = '토레스 EVX' AND vt.trim_name = 'E7');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Cooper SE', '소형 해치백', FALSE, 32.6, 159, 114, 11, 50, 4.5, 36, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = 'MINI Electric'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = 'MINI Electric' AND vt.trim_name = 'Cooper SE');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E', '소형 해치백', TRUE, 54.2, 320, 230, 11, 95, 4.8, 30, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'E');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'JCW', '소형 해치백', TRUE, 54.2, 320, 230, 11, 95, 4.8, 30, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'JCW');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SE', '소형 해치백', TRUE, 54.2, 320, 230, 11, 95, 4.8, 30, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'SE');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E', '소형 크로스오버', TRUE, 54.2, 310, 223, 11, 95, 4.6, 31, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '에이스맨' AND vt.trim_name = 'E');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'JCW', '소형 크로스오버', TRUE, 54.2, 310, 223, 11, 95, 4.6, 31, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '에이스맨' AND vt.trim_name = 'JCW');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SE', '소형 크로스오버', TRUE, 54.2, 310, 223, 11, 95, 4.6, 31, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '에이스맨' AND vt.trim_name = 'SE');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'E', '준중형 SUV', TRUE, 66.5, 350, 252, 11, 130, 4.5, 29, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'E');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'JCW', '준중형 SUV', TRUE, 66.5, 350, 252, 11, 130, 4.5, 29, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'JCW');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SE ALL4', '준중형 SUV', TRUE, 66.5, 350, 252, 11, 130, 4.5, 29, 'https://www.mini.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = 'MINI' AND vm2.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'SE ALL4');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT-Line 롱레인지 2WD', '소형 SUV', TRUE, 81.4, 501, 421, 11, 128, 5.4, 31, 'https://www.kia.com/kr/vehicles/ev3/features / 기아 공식 제원 대표값 / 조선비즈 기사: EV3 저온비율 84.1%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV3' AND vt.trim_name = 'GT-Line 롱레인지 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD', '소형 SUV', TRUE, 81.4, 501, 421, 11, 128, 5.4, 31, 'https://www.kia.com/kr/vehicles/ev3/features / 기아 공식 제원 대표값 / 조선비즈 기사: EV3 저온비율 84.1%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV3' AND vt.trim_name = '롱레인지 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '소형 SUV', TRUE, 58.3, 350, 294, 11, 128, 5.4, 31, 'https://www.kia.com/kr/vehicles/ev3/features / 기아 공식 제원 대표값 / 조선비즈 2024-10-25: EV3 스탠다드 저온비율 84.1%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV3' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT-Line', '준중형 세단·해치백', TRUE, 81.4, 502, 376, 11, 128, 5.5, 31, 'https://www.kia.com/kr/vehicles/ev4/features / 기아 공식 제원: 롱레인지 2WD 19인치 GT-Line / 프레스9 2026-01-12: EV4 4WD 저온 복합 376km / https://www.energy-news.co.kr/news/articleView.html?idxno=222118', '2026-07-17', '세단 기준 대표값 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 국내 실제 신규등록/판매 확인: 2025년 전기차 판매 통계에 EV4 포함 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV4' AND vt.trim_name = 'GT-Line');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '준중형 세단·해치백', TRUE, 81.4, 533, 437, 11, 128, 5.8, 31, 'https://www.kia.com/kr/vehicles/ev4/features / 기아 공식 제원: 롱레인지 2WD 17인치 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.energy-news.co.kr/news/articleView.html?idxno=222118', '2026-07-17', '세단 기준 대표값 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 국내 실제 신규등록/판매 확인: 2025년 전기차 판매 통계에 EV4 포함 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV4' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Standard', '준중형 세단·해치백', TRUE, 81.4, 382, 313, 11, 128, 5.8, 31, 'https://www.kia.com/kr/vehicles/ev4/features / 기아 공식 제원: 스탠다드 2WD 17인치 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.energy-news.co.kr/news/articleView.html?idxno=222118', '2026-07-17', '세단 기준 대표값 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 국내 실제 신규등록/판매 확인: 2025년 전기차 판매 통계에 EV4 포함 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV4' AND vt.trim_name = 'Standard');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '준중형 SUV', TRUE, 81.4, 460, 377, 11, 150, 5, 30, 'https://www.kia.com/kr / 기아 공식 제원: 롱레인지 2WD / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.epnc.co.kr/news/articleView.html?idxno=323312', '2026-07-17', '국내 인증 세부값은 트림별 확인 필요 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 국내 실제 판매 확인: 2025년 9월 272대 판매, 이후 출고·판매 지속 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV5' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Standard', '준중형 SUV', TRUE, 81.4, 390, 320, 11, 150, 5, 30, 'https://www.kia.com/kr / 기아 공식 제원 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.epnc.co.kr/news/articleView.html?idxno=323312', '2026-07-17', '국내 인증 세부값은 트림별 확인 필요 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 국내 실제 판매 확인: 2025년 9월 272대 판매, 이후 출고·판매 지속 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV5' AND vt.trim_name = 'Standard');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT AWD', '중형 크로스오버', TRUE, 84, 355, 323, 11, 258, 3.9, 18, 'https://www.kia.com/kr/vehicles/ev6/features / 기아 공식 제원: EV6 GT 대표값 / 조선비즈 2024-10-25: EV6 GT 저온비율 90.9%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV6' AND vt.trim_name = 'GT AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD', '중형 크로스오버', TRUE, 84, 494, 446, 11, 258, 5.2, 18, 'https://www.kia.com/kr/vehicles/ev6/features / 기아 공식 제원: 롱레인지 2WD 19인치(빌트인캠 미적용) / 매일경제 2021-11-22: EV6 롱레인지 2WD 19인치 상온 483km/저온 446km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV6' AND vt.trim_name = '롱레인지 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 AWD', '중형 크로스오버', TRUE, 84, 461, 378, 11, 258, 4.9, 18, 'https://www.kia.com/kr/vehicles/ev6/features / 기아 공식 제원: 롱레인지 AWD 대표 19인치 기준 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV6' AND vt.trim_name = '롱레인지 AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '중형 크로스오버', TRUE, NULL, 382, 313, 11, 258, 5.1, 18, 'https://www.kia.com/kr/vehicles/ev6/features / 기아 공식 제원: 스탠다드 2WD 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / battery_kwh는 "트림별 공식값 확인 필요"로 원본에 명시 — NULL 처리 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV6' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '4WD', '대형 SUV', TRUE, 99.8, 445, 365, 11, 250, 3.8, 24, 'https://www.kia.com/kr/vehicles/ev9/features / 기아 공식 제원: 롱레인지 4WD 19인치 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV9' AND vt.trim_name = '4WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT AWD', '대형 SUV', TRUE, 99.8, 408, 335, 11, 250, 3.4, 24, 'https://www.kia.com/kr/vehicles/ev9/features / 기아 공식 제원: EV9 GT 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV9' AND vt.trim_name = 'GT AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT-Line 4WD', '대형 SUV', TRUE, 99.8, 445, 365, 11, 250, 3.8, 24, 'https://www.kia.com/kr/vehicles/ev9/features / 기아 공식 제원: 롱레인지 4WD 19인치 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV9' AND vt.trim_name = 'GT-Line 4WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD 19인치', '대형 SUV', TRUE, 99.8, 501, 363, 11, 250, 4.2, 24, 'https://www.kia.com/kr/vehicles/ev9/features / 기아 공식 제원: 롱레인지 2WD 19인치 / 환경부 공개 저온성능비율 72.4%와 국내 상온 501km 기준 환산(약 363km)', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온 복합 주행거리 반영 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'EV9' AND vt.trim_name = '롱레인지 2WD 19인치');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Cargo', 'PBV·승합/화물', TRUE, 71.2, 400, 312, 11, 150, 4.8, 30, 'https://www.kia.com/kr/pbv / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://auto.danawa.com/news/?Tab=N1&Work=detail&no=5948910', '2026-07-17', '국내 인증 트림별 수치 확인 필요 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 국내 실제 판매 확인: 기아 2025년 연간 판매실적에 PV5 포함 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'PV5' AND vt.trim_name = 'Cargo');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Passenger', 'PBV·승합/화물', TRUE, 71.2, 400, 312, 11, 150, 4.8, 30, 'https://www.kia.com/kr/pbv / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://auto.danawa.com/news/?Tab=N1&Work=detail&no=5948910', '2026-07-17', '국내 인증 트림별 수치 확인 필요 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 국내 실제 판매 확인: 기아 2025년 연간 판매실적에 PV5 포함 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = 'PV5' AND vt.trim_name = 'Passenger');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Noblesse', '소형 SUV', FALSE, 64, 385, 346, 7.2, 100, 5.3, 54, 'https://www.kia.com/kr / 현대차그룹 기사: 니로 EV 상온 대비 저온비율 약 90%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '니로 EV 1세대' AND vt.trim_name = 'Noblesse');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Prestige', '소형 SUV', FALSE, 64, 385, 346, 7.2, 100, 5.3, 54, 'https://www.kia.com/kr / 현대차그룹 기사: 니로 EV 상온 대비 저온비율 약 90%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '니로 EV 1세대' AND vt.trim_name = 'Prestige');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '1인승 밴', '경형 승용·밴', TRUE, 35.2, 205, 154, 7, 150, 5.1, 40, 'https://www.kia.com/kr/vehicles/ray-ev/features / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '더 기아 레이 EV' AND vt.trim_name = '1인승 밴');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '2인승 밴', '경형 승용·밴', TRUE, 35.2, 205, 154, 7, 150, 5.1, 40, 'https://www.kia.com/kr/vehicles/ray-ev/features / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '더 기아 레이 EV' AND vt.trim_name = '2인승 밴');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '4인승', '경형 승용·밴', TRUE, 35.2, 205, 154, 7, 150, 5.1, 40, 'https://www.kia.com/kr/vehicles/ray-ev/features / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '더 기아 레이 EV' AND vt.trim_name = '4인승');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Air', '소형 SUV', TRUE, 64.8, 401, 329, 11, 85, 5.3, 43, 'https://www.kia.com/kr/vehicles/niro-ev/features / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Air');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Earth', '소형 SUV', TRUE, 64.8, 401, 329, 11, 85, 5.3, 43, 'https://www.kia.com/kr/vehicles/niro-ev/features / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Earth');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '단일 트림', '경형 박스카', FALSE, 16.4, 91, 68, 3.3, 50, 5, 25, 'https://www.kia.com/kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '레이 EV 1세대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '레이 EV 1세대' AND vt.trim_name = '단일 트림');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '1톤 2WD 초장축', '소형 전기 화물차', TRUE, 60.4, 211, 152, 7.2, 100, 3.1, 47, 'https://www.kia.com/kr/vehicles/bongo3-ev/features / 부산일보/소비자단체 분석: 봉고3 EV 저온에서 28% 감소', '2026-07-17', '적재·온도 조건 영향 큼 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '봉고 III EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '봉고 III EV' AND vt.trim_name = '1톤 2WD 초장축');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '18MY', '소형 크로스오버', FALSE, 30, 180, 140, 6.6, 50, 5.2, 33, 'https://www.kia.com/kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '쏘울 EV' AND vt.trim_name = '18MY');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '19MY', '소형 크로스오버', FALSE, 30, 180, 140, 6.6, 50, 5.2, 33, 'https://www.kia.com/kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '쏘울 EV' AND vt.trim_name = '19MY');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Noblesse', '소형 크로스오버', FALSE, 64, 386, 301, 7.2, 100, 5.4, 54, 'https://www.kia.com/kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Noblesse');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Prestige', '소형 크로스오버', FALSE, 64, 386, 301, 7.2, 100, 5.4, 54, 'https://www.kia.com/kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×78%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '기아' AND vm2.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Prestige');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '24kWh', '준중형 해치백', FALSE, 40, 231, 157, 6.6, 50, 5.1, 40, 'https://www.nissan.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '한국 공식 판매 종료 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '닛산' AND vm2.model_name = '리프' AND vt.trim_name = '24kWh');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '40kWh', '준중형 해치백', FALSE, 40, 231, 157, 6.6, 50, 5.1, 40, 'https://www.nissan.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '한국 공식 판매 종료 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '닛산' AND vm2.model_name = '리프' AND vt.trim_name = '40kWh');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '450e', '중형 SUV', TRUE, 77, 377, 256, 11, 150, 4.3, 30, 'https://www.lexus.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '렉서스' AND vm2.model_name = 'RZ' AND vt.trim_name = '450e');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '550e', '중형 SUV', TRUE, 77, 377, 256, 11, 150, 4.3, 30, 'https://www.lexus.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '렉서스' AND vm2.model_name = 'RZ' AND vt.trim_name = '550e');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RZ 300e', '중형 SUV', TRUE, 77, 377, 256, 11, 150, 4.3, 30, 'https://www.lexus.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '렉서스' AND vm2.model_name = 'RZ' AND vt.trim_name = 'RZ 300e');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Luxury', '준중형 SUV', FALSE, 54.3, 233, 158, 6.6, 50, 4.7, 80, 'https://www.lexus.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'UX 300e'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '렉서스' AND vm2.model_name = 'UX 300e' AND vt.trim_name = 'Luxury');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'R', '대형 GT 세단', TRUE, 102, 486, 425, 22, 350, 3.8, 18, 'https://www.lotuscars.com/ko-KR / 모터그래프 2025-01-07: 에메야 저온 최대 425km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '로터스' AND vm2.model_name = '에메야' AND vt.trim_name = 'R');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'S', '대형 GT 세단', TRUE, 102, 486, 425, 22, 350, 3.8, 18, 'https://www.lotuscars.com/ko-KR / 모터그래프 2025-01-07: 에메야 저온 최대 425km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '로터스' AND vm2.model_name = '에메야' AND vt.trim_name = 'S');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'R', '대형 SUV', TRUE, 112, 463, 333, 22, 350, 3.5, 20, 'https://www.lotuscars.com/ko-KR / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '로터스' AND vm2.model_name = '엘레트라' AND vt.trim_name = 'R');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'S', '대형 SUV', TRUE, 112, 463, 333, 22, 350, 3.5, 20, 'https://www.lotuscars.com/ko-KR / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '로터스' AND vm2.model_name = '엘레트라' AND vt.trim_name = 'S');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Black Badge', '대형 럭셔리 쿠페', TRUE, 102, 383, 276, 22, 195, 3.2, 34, 'https://www.rolls-roycemotorcars.com/seoul/en_GB/showroom/spectre.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://auto.danawa.com/auto/?Brand=385&Tab=record&Work=brand&pcUse=y', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 국내 실제 등록/판매 확인: 판매실적에 Spectre 전기차 등록 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '롤스로이스' AND vm2.model_name = '스펙터' AND vt.trim_name = 'Black Badge');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Spectre', '대형 럭셔리 쿠페', TRUE, 102, 383, 276, 22, 195, 3.2, 34, 'https://www.rolls-roycemotorcars.com/seoul/en_GB/showroom/spectre.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://auto.danawa.com/auto/?Brand=385&Tab=record&Work=brand&pcUse=y', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 국내 실제 등록/판매 확인: 판매실적에 Spectre 전기차 등록 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '롤스로이스' AND vm2.model_name = '스펙터' AND vt.trim_name = 'Spectre');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RE', '준중형 세단', FALSE, 35.9, 213, 145, 7, 43, 4.5, 60, 'https://www.renault.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', 'DC 급속 미지원 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm2.model_name = 'SM3 Z.E.' AND vt.trim_name = 'RE');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SE', '준중형 세단', FALSE, 35.9, 213, 145, 7, 43, 4.5, 60, 'https://www.renault.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', 'DC 급속 미지원 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm2.model_name = 'SM3 Z.E.' AND vt.trim_name = 'SE');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '중형 SUV', TRUE, 87, 460, 313, 22, 150, 4.5, 37, 'https://www.renault.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.autoview.co.kr/ko-kr/articles/96801', '2026-07-17', '국내 판매·인증 세부 트림 확인 필요 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 국내 실제 고객 인도 시작 확인: 2025-08-21 / 급속 SOC 기준: 15→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '세닉 E-Tech 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm2.model_name = '세닉 E-Tech 일렉트릭' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Intens', '소형 해치백', FALSE, 54.5, 309, 210, 22, 50, 4.8, 70, 'https://www.renault.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm2.model_name = '조에(ZOE)' AND vt.trim_name = 'Intens');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Zen', '소형 해치백', FALSE, 54.5, 309, 210, 22, 50, 4.8, 70, 'https://www.renault.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '르노코리아' AND vm2.model_name = '조에(ZOE)' AND vt.trim_name = 'Zen');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Folgore', 'GT 쿠페', TRUE, 92.5, 321, 231, 22, 270, 3.3, 18, 'https://www.maserati.com/kr/ko / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그란투리스모 폴고레'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '마세라티' AND vm2.model_name = '그란투리스모 폴고레' AND vt.trim_name = 'Folgore');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Folgore', '중형 SUV', TRUE, 105, 426, 307, 22, 150, 3.6, 29, 'https://www.maserati.com/kr/ko / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://car.encar.com/list/car/%EB%A7%88%EC%84%B8%EB%9D%BC%ED%8B%B0', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 국내 실제 등록 차량 확인: 2025년식 중고 등록차 존재 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그레칼레 폴고레'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '마세라티' AND vm2.model_name = '그레칼레 폴고레' AND vt.trim_name = 'Folgore');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '250+', '준중형 SUV', TRUE, 70.5, 367, 204, 11, 100, 4.7, 35, 'https://www.mercedes-benz.co.kr / 모터그래프 기사: EQA 250 저온 204km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQA' AND vt.trim_name = '250+');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'EQA 250', '준중형 SUV', TRUE, 70.5, 367, 204, 11, 100, 4.7, 35, 'https://www.mercedes-benz.co.kr / 환경부 공개 저온성능비율 80.7%와 국내 상온 367km 기준 환산(약 296km) / 모터그래프 2021-07-12: EQA 250 상온 302.8km/저온 204km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온 복합 주행거리 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQA' AND vt.trim_name = 'EQA 250');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'EQB 300 4MATIC', '준중형 SUV', TRUE, 66.5, 313, 225, 11, 100, 4.1, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQB'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQB' AND vt.trim_name = 'EQB 300 4MATIC');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'EQC 400 4MATIC', '중형 SUV', FALSE, 80, 309, 222, 7.4, 110, 3.2, 40, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQC'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQC' AND vt.trim_name = 'EQC 400 4MATIC');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '350+', '준대형 세단', TRUE, 96.1, 486, 350, 11, 170, 4.2, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE' AND vt.trim_name = '350+');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AMG 53', '준대형 세단', TRUE, 96.1, 486, 350, 11, 170, 4.2, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE' AND vt.trim_name = 'AMG 53');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'EQE 300', '준대형 세단', TRUE, 96.1, 486, 350, 11, 170, 4.2, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE' AND vt.trim_name = 'EQE 300');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '350 4MATIC', '대형 SUV', TRUE, 96.1, 401, 289, 11, 170, 3.8, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE SUV' AND vt.trim_name = '350 4MATIC');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '500', '대형 SUV', TRUE, 96.1, 401, 289, 11, 170, 3.8, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE SUV' AND vt.trim_name = '500');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AMG', '대형 SUV', TRUE, 96.1, 401, 289, 11, 170, 3.8, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQE SUV' AND vt.trim_name = 'AMG');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '450 4MATIC', '대형 세단', TRUE, 118, 520, 374, 22, 200, 3.8, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS' AND vt.trim_name = '450 4MATIC');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '450+', '대형 세단', TRUE, 118, 520, 374, 22, 200, 3.8, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS' AND vt.trim_name = '450+');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AMG 53', '대형 세단', TRUE, 118, 520, 374, 22, 200, 3.8, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS' AND vt.trim_name = 'AMG 53');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '450', '대형 SUV', TRUE, 118, 447, 322, 22, 200, 3.5, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS SUV' AND vt.trim_name = '450');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '580', '대형 SUV', TRUE, 118, 447, 322, 22, 200, 3.5, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS SUV' AND vt.trim_name = '580');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Maybach 680', '대형 SUV', TRUE, 118, 447, 322, 22, 200, 3.5, 31, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'EQS SUV' AND vt.trim_name = 'Maybach 680');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'G 580', '대형 오프로더', TRUE, 116, 392, 282, 11, 200, 3, 32, 'https://www.mercedes-benz.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.autoview.co.kr/ko-kr/articles/95927', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 국내 실제 판매 확인: 한국 판매 61대 보도 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'G 580 with EQ Technology'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '메르세데스-벤츠' AND vm2.model_name = 'G 580 with EQ Technology' AND vt.trim_name = 'G 580');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Single', '준중형 쿠페 SUV', TRUE, 82, 407, 293, 11, 205, 4.3, 28, 'https://www.volvocars.com/kr/cars/ec40-electric/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '명칭 변경 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '볼보' AND vm2.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Single');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Twin Motor', '준중형 쿠페 SUV', TRUE, 82, 407, 293, 11, 205, 4.3, 28, 'https://www.volvocars.com/kr/cars/ec40-electric/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '명칭 변경 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '볼보' AND vm2.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Twin Motor');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Single Motor Extended Range', '소형 SUV', TRUE, 69, 351, 253, 11, 153, 4.8, 26, 'https://www.volvocars.com/kr/cars/ex30-electric/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'EX30'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '볼보' AND vm2.model_name = 'EX30' AND vt.trim_name = 'Single Motor Extended Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Single', '준중형 SUV', TRUE, 82, 389, 280, 11, 205, 4.2, 28, 'https://www.volvocars.com/kr/cars/ex40-electric/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '명칭 변경 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '볼보' AND vm2.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Single');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Twin Motor', '준중형 SUV', TRUE, 82, 389, 280, 11, 205, 4.2, 28, 'https://www.volvocars.com/kr/cars/ex40-electric/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '명칭 변경 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '볼보' AND vm2.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Twin Motor');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Premier', '소형 SUV', FALSE, 66, 403, 279, 11, 55, 5.5, 60, 'https://www.chevrolet.co.kr / 매일경제 2021-11-22: 볼트 EUV 상온 403km/저온 279km', '2026-07-17', '저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EUV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm2.model_name = '볼트 EUV' AND vt.trim_name = 'Premier');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'LT', '소형 해치백', FALSE, 66, 414, 273, 11, 55, 5.4, 60, 'https://www.chevrolet.co.kr / 환경부 공개 저온성능비율 65.9%와 국내 상온 414km 기준 환산(약 273km)', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온 복합 주행거리 반영 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm2.model_name = '볼트 EV' AND vt.trim_name = 'LT');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Premier', '소형 해치백', FALSE, 66, 414, 273, 11, 55, 5.4, 60, 'https://www.chevrolet.co.kr / 환경부 공개 저온성능비율 65.9%와 국내 상온 414km 기준 환산(약 273km)', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온 복합 주행거리 반영 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm2.model_name = '볼트 EV' AND vt.trim_name = 'Premier');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '단일 트림', '경형 해치백', FALSE, 18.4, 128, 87, 3.3, 50, 5.6, 20, 'https://www.chevrolet.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '스파크 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '쉐보레' AND vm2.model_name = '스파크 EV' AND vt.trim_name = '단일 트림');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '40', '준중형 쿠페 SUV', TRUE, 82, 409, 269, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 조선비즈 2024-10-25: Q4 Sportback e-tron 저온비율 65.7%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '45', '준중형 쿠페 SUV', TRUE, 82, 409, 294, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '45');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '50 quattro', '준중형 쿠페 SUV', TRUE, 82, 409, 294, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '50 quattro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '40', '준중형 SUV', TRUE, 82, 411, 268, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 조선비즈 2024-10-25: Q4 e-tron 상온 411km/저온 268km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 e-tron' AND vt.trim_name = '40');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '45', '준중형 SUV', TRUE, 82, 411, 296, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 e-tron' AND vt.trim_name = '45');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '50 quattro', '준중형 SUV', TRUE, 82, 411, 296, 11, 175, 4.3, 28, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q4 e-tron' AND vt.trim_name = '50 quattro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SQ6', '중형 SUV', TRUE, 100, 468, 337, 11, 270, 4.2, 21, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q6 e-tron' AND vt.trim_name = 'SQ6');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'performance', '중형 SUV', TRUE, 100, 468, 337, 11, 270, 4.2, 21, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q6 e-tron' AND vt.trim_name = 'performance');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'quattro', '중형 SUV', TRUE, 100, 468, 337, 11, 270, 4.2, 21, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q6 e-tron' AND vt.trim_name = 'quattro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '50', '대형 SUV', FALSE, 114, 368, 265, 11, 170, 3.1, 31, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q8 e-tron' AND vt.trim_name = '50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '55', '대형 SUV', FALSE, 114, 368, 265, 11, 170, 3.1, 31, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q8 e-tron' AND vt.trim_name = '55');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'SQ8', '대형 SUV', FALSE, 114, 368, 265, 11, 170, 3.1, 31, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'Q8 e-tron' AND vt.trim_name = 'SQ8');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '50', '대형 SUV', FALSE, 95, 307, 221, 11, 150, 3, 30, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', 'Q8 e-tron으로 개명·후속 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '55', '대형 SUV', FALSE, 95, 307, 221, 11, 150, 3, 30, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', 'Q8 e-tron으로 개명·후속 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '55');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RS', '대형 GT 세단', TRUE, 105, 479, 345, 11, 320, 4, 18, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron GT' AND vt.trim_name = 'RS');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'S', '대형 GT 세단', TRUE, 105, 479, 345, 11, 320, 4, 18, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron GT' AND vt.trim_name = 'S');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'quattro', '대형 GT 세단', TRUE, 105, 479, 345, 11, 320, 4, 18, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron GT' AND vt.trim_name = 'quattro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '50', '대형 쿠페 SUV', FALSE, 95, 304, 219, 11, 150, 3, 30, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron Sportback' AND vt.trim_name = '50');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '55', '대형 쿠페 SUV', FALSE, 95, 304, 219, 11, 150, 3, 30, 'https://www.audi.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '아우디' AND vm2.model_name = 'e-tron Sportback' AND vt.trim_name = '55');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'EV400', '중형 SUV', FALSE, 90, 333, 226, 11, 100, 3.5, 40, 'https://www.jaguar.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '재규어' AND vm.model_name = 'I-PACE'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '재규어' AND vm2.model_name = 'I-PACE' AND vt.trim_name = 'EV400');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AWD', '대형 세단', FALSE, 87.2, 427, 411, 11, 187, 4.3, 21, 'https://www.genesis.com/kr/ko / 환경부 공개 저온성능비율 94.9%와 국내 상온 427km 기준 환산(약 405km) / 브런치/환경부 자료 정리: G80 전동화 상온 433km/저온 411km', '2026-07-17', '후속/판매 여부 변동 가능 / 저온 복합 주행거리 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified G80'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '제네시스' AND vm2.model_name = 'Electrified G80' AND vt.trim_name = 'AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AWD', '중형 SUV', TRUE, 84, 423, 347, 11, 240, 4.6, 19, 'https://www.genesis.com/kr/ko/models/luxury-suv-genesis/electrified-gv70/highlights.html / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified GV70'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '제네시스' AND vm2.model_name = 'Electrified GV70' AND vt.trim_name = 'AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '중형 크로스오버', TRUE, 84, 481, 416, 11, 258, 5.1, 18, 'https://www.genesis.com/kr/ko/models/luxury-suv-genesis/gv60/highlights.html / 제네시스 국내 인증 대표값 / 브런치/환경부 자료 정리: GV60 스탠다드 2WD 19인치 저온 416km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '제네시스' AND vm2.model_name = 'GV60' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 AWD', '중형 크로스오버', TRUE, 84, 451, 378, 11, 258, 4.8, 18, 'https://www.genesis.com/kr/ko/models/luxury-suv-genesis/gv60/highlights.html / 제네시스 국내 인증 대표값 / 조선비즈 2024-10-25: GV60 스탠다드 AWD 19인치 상온 403km/저온 378km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '제네시스' AND vm2.model_name = 'GV60' AND vt.trim_name = '스탠다드 AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '퍼포먼스 AWD', '중형 크로스오버', TRUE, 84, 368, 302, 11, 258, 4.1, 18, 'https://www.genesis.com/kr/ko/models/luxury-suv-genesis/gv60/highlights.html / 제네시스 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '제네시스' AND vm2.model_name = 'GV60' AND vt.trim_name = '퍼포먼스 AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Altitude', '소형 SUV', TRUE, 54, 292, 274, 11, 100, 4.5, 24, 'https://www.jeep.co.kr / 조선비즈 2024-10-25: 어벤저 상온 295km/저온 274km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '지프' AND vm2.model_name = '어벤저 EV' AND vt.trim_name = 'Altitude');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Summit', '소형 SUV', TRUE, 54, 292, 274, 11, 100, 4.5, 24, 'https://www.jeep.co.kr / 조선비즈 2024-10-25: 어벤저 상온 295km/저온 274km', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 20→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '지프' AND vm2.model_name = '어벤저 EV' AND vt.trim_name = 'Summit');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Sport', '대형 SUV', TRUE, 102, 465, 316, 19.2, 190, 3.9, 30, 'https://www.cadillac.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://news.gm-korea.co.kr/ko/home/newsroom.detail.html/Pages/news/kr/ko/2024/jul/0722_july_Cadillac_LYRIQStartofsales.html', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×68%), 공식인증값 아님 / 국내 실제 고객 인도 시작 및 초도 물량 판매 확인 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '캐딜락' AND vm.model_name = '리릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '캐딜락' AND vm2.model_name = '리릭' AND vt.trim_name = 'Sport');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range AWD', '중형 세단', TRUE, NULL, 488, 440, 11, 250, 5.4, 27, 'https://www.tesla.com/ko_kr/model3 / 브런치/환경부 자료 정리: 모델3 롱레인지 상온 527.9km/저온 440.1km', '2026-07-17', '배터리 용량은 제조사 비공개로 추정치 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model 3' AND vt.trim_name = 'Long Range AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Performance AWD', '중형 세단', TRUE, NULL, 488, 376, 11, 250, 5.4, 27, 'https://www.tesla.com/ko_kr/model3 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '배터리 용량은 제조사 비공개로 추정치 / 저온값 유형: 검색 기반 추정값(상온×77%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model 3' AND vt.trim_name = 'Performance AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RWD', '중형 세단', TRUE, NULL, 488, 376, 11, 250, 5.4, 27, 'https://www.tesla.com/ko_kr/model3 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '배터리 용량은 제조사 비공개로 추정치 / 저온값 유형: 검색 기반 추정값(상온×77%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model 3' AND vt.trim_name = 'RWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '대형 패스트백', TRUE, 100, 555, 461, 11, 250, 4.1, 30, 'https://www.tesla.com/ko_kr/models / 브런치/환경부 자료 정리: 모델S 롱레인지 플러스 상온 520km/저온 461km', '2026-07-17', '인증·커넥터가 연식별 상이 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model S' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Plaid', '대형 패스트백', TRUE, 100, 555, 427, 11, 250, 4.1, 30, 'https://www.tesla.com/ko_kr/models / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '인증·커넥터가 연식별 상이 / 저온값 유형: 검색 기반 추정값(상온×77%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model S' AND vt.trim_name = 'Plaid');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '대형 SUV', TRUE, 100, 478, 368, 11, 250, 3.7, 30, 'https://www.tesla.com/ko_kr/modelx / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '배터리 용량은 추정치 / 저온값 유형: 검색 기반 추정값(상온×77%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model X' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Plaid', '대형 SUV', TRUE, 100, 478, 368, 11, 250, 3.7, 30, 'https://www.tesla.com/ko_kr/modelx / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '배터리 용량은 추정치 / 저온값 유형: 검색 기반 추정값(상온×77%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model X' AND vt.trim_name = 'Plaid');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range AWD', '중형 SUV', TRUE, NULL, 476, 432, 11, 250, 5.1, 27, 'https://www.tesla.com/ko_kr/modely / 브런치/환경부 자료 정리: 모델Y 롱레인지 상온 511km/저온 432.5km', '2026-07-17', '배터리 용량은 추정치 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model Y' AND vt.trim_name = 'Long Range AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Performance AWD', '중형 SUV', TRUE, NULL, 476, 366, 11, 250, 5.1, 27, 'https://www.tesla.com/ko_kr/modely / 조선비즈 2024-10-25: 모델Y 퍼포먼스 저온비율 77.0%', '2026-07-17', '배터리 용량은 추정치 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model Y' AND vt.trim_name = 'Performance AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RWD', '중형 SUV', TRUE, NULL, 476, 370, 11, 250, 5.1, 27, 'https://www.tesla.com/ko_kr/modely / 조선비즈 2024-10-25: 모델Y RWD 저온비율 77.8%', '2026-07-17', '배터리 용량은 추정치 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '테슬라' AND vm2.model_name = 'Model Y' AND vt.trim_name = 'RWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '4S', '중형 SUV', TRUE, 100, 474, 341, 11, 270, 4, 21, 'https://www.porsche.com/korea/ko/models/macan/macan-electric-models/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '마칸 일렉트릭' AND vt.trim_name = '4S');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Macan 4', '중형 SUV', TRUE, 100, 474, 341, 11, 270, 4, 21, 'https://www.porsche.com/korea/ko/models/macan/macan-electric-models/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Macan 4');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Turbo', '중형 SUV', TRUE, 100, 474, 341, 11, 270, 4, 21, 'https://www.porsche.com/korea/ko/models/macan/macan-electric-models/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Turbo');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '4S', '대형 스포츠 세단·왜건', TRUE, 105, 477, 343, 22, 320, 3.8, 18, 'https://www.porsche.com/korea/ko/models/taycan/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '신형 Performance Battery Plus 기준 대표값 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '타이칸' AND vt.trim_name = '4S');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Cross Turismo', '대형 스포츠 세단·왜건', TRUE, 105, 477, 343, 22, 320, 3.8, 18, 'https://www.porsche.com/korea/ko/models/taycan/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '신형 Performance Battery Plus 기준 대표값 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '타이칸' AND vt.trim_name = 'Cross Turismo');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'RWD', '대형 스포츠 세단·왜건', TRUE, 105, 477, 343, 22, 320, 3.8, 18, 'https://www.porsche.com/korea/ko/models/taycan/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '신형 Performance Battery Plus 기준 대표값 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '타이칸' AND vt.trim_name = 'RWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Turbo', '대형 스포츠 세단·왜건', TRUE, 105, 477, 343, 22, 320, 3.8, 18, 'https://www.porsche.com/korea/ko/models/taycan/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '신형 Performance Battery Plus 기준 대표값 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '포르쉐' AND vm2.model_name = '타이칸' AND vt.trim_name = 'Turbo');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Pro', '준중형 SUV', TRUE, 82, 424, 294, 11, 175, 4.7, 28, 'https://www.volkswagen.co.kr / 조선비즈 2024-10-25: ID.4 Pro 저온비율 69.3%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폭스바겐' AND vm2.model_name = 'ID.4' AND vt.trim_name = 'Pro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Pro Lite', '준중형 SUV', TRUE, 82, 424, 294, 11, 175, 4.7, 28, 'https://www.volkswagen.co.kr / 조선비즈 2024-10-25: ID.4 Pro 저온비율 69.3%', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폭스바겐' AND vm2.model_name = 'ID.4' AND vt.trim_name = 'Pro Lite');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Pro', '준중형 쿠페 SUV', TRUE, 82, 434, 312, 11, 175, 4.7, 28, 'https://www.volkswagen.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폭스바겐' AND vm2.model_name = 'ID.5' AND vt.trim_name = 'Pro');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '중형 패스트백', TRUE, 82, 449, 323, 11, 205, 4.5, 28, 'https://www.polestar.com/kr/polestar-2/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폴스타' AND vm2.model_name = 'Polestar 2' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Performance', '중형 패스트백', TRUE, 82, 449, 323, 11, 205, 4.5, 28, 'https://www.polestar.com/kr/polestar-2/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폴스타' AND vm2.model_name = 'Polestar 2' AND vt.trim_name = 'Performance');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Standard', '중형 패스트백', TRUE, 82, 449, 323, 11, 205, 4.5, 28, 'https://www.polestar.com/kr/polestar-2/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폴스타' AND vm2.model_name = 'Polestar 2' AND vt.trim_name = 'Standard');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Dual Motor', '중형 쿠페 SUV', TRUE, 100, 511, 368, 22, 200, 4.3, 30, 'https://www.polestar.com/kr/polestar-4/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.etnews.com/20260629000289', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / KAIDA 누적 등록 기준 국내 실제 판매 확인 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폴스타' AND vm2.model_name = 'Polestar 4' AND vt.trim_name = 'Dual Motor');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range Single', '중형 쿠페 SUV', TRUE, 100, 511, 368, 22, 200, 4.3, 30, 'https://www.polestar.com/kr/polestar-4/ / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정 / https://www.etnews.com/20260629000289', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×72%), 공식 인증값 아님 / KAIDA 누적 등록 기준 국내 실제 판매 확인 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '폴스타' AND vm2.model_name = 'Polestar 4' AND vt.trim_name = 'Long Range Single');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Allure', '소형 SUV', FALSE, 50, 260, 177, 11, 100, 4.3, 30, 'https://www.peugeot.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '푸조' AND vm2.model_name = 'e-2008' AND vt.trim_name = 'Allure');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT', '소형 SUV', FALSE, 50, 260, 177, 11, 100, 4.3, 30, 'https://www.peugeot.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '푸조' AND vm2.model_name = 'e-2008' AND vt.trim_name = 'GT');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Allure', '소형 해치백', FALSE, 50, 244, 166, 11, 100, 4.4, 30, 'https://www.peugeot.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '푸조' AND vm2.model_name = 'e-208' AND vt.trim_name = 'Allure');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'GT', '소형 해치백', FALSE, 50, 244, 166, 11, 100, 4.4, 30, 'https://www.peugeot.co.kr / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×68%), 공식 인증값 아님 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '푸조' AND vm2.model_name = 'e-208' AND vt.trim_name = 'GT');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '샤시캡', '소형 전기 상용차', TRUE, 76.1, 317, 238, 11, 170, 3.6, 20, 'https://www.hyundai.com/kr/ko/e/vehicles/st1/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '상용차 적재 조건에 따라 거리 차이 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = 'ST1' AND vt.trim_name = '샤시캡');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '카고', '소형 전기 상용차', TRUE, 76.1, 317, 238, 11, 170, 3.6, 20, 'https://www.hyundai.com/kr/ko/e/vehicles/st1/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '상용차 적재 조건에 따라 거리 차이 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = 'ST1' AND vt.trim_name = '카고');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '특장', '소형 전기 상용차', TRUE, 76.1, 317, 238, 11, 170, 3.6, 20, 'https://www.hyundai.com/kr/ko/e/vehicles/st1/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '상용차 적재 조건에 따라 거리 차이 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = 'ST1' AND vt.trim_name = '특장');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD', '소형 SUV', TRUE, 64.8, 417, 342, 11, 100, 5.5, 43, 'https://www.hyundai.com/kr/ko/e/vehicles/kona-electric/intro / 현대 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '롱레인지 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '소형 SUV', TRUE, 48.6, 311, 255, 11, 100, 5.5, 43, 'https://www.hyundai.com/kr/ko/e/vehicles/kona-electric/intro / 현대 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'N AWD', '중형 크로스오버', TRUE, 84, 351, 319, 11, 260, 3.7, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq5/intro / 현대 국내 인증 대표값 / 조선비즈 2024-10-25: 아이오닉5 N 저온비율 90.9%', '2026-07-17', 'N은 84kWh·고성능 사양 / 상온 주행거리·전비 공식 제원 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 5' AND vt.trim_name = 'N AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD 19인치', '중형 크로스오버', TRUE, 84, 489, 399, 11, 260, 5.2, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq5/intro / 현대 국내 인증 대표값 / 무공해차 통합누리집 2026 지급대상 차종: 더 뉴 아이오닉5 2WD 롱레인지 19인치 상온 489km/저온 380km / 브런치/환경부 자료 정리: 77.4kWh 아이오닉5 롱레인지 2WD 19인치 저온 399km', '2026-07-17', 'N은 84kWh·고성능 사양 / 상온 주행거리·전비 공식 제원 반영 / 저온 복합 주행거리 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 2WD 19인치');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 AWD', '중형 크로스오버', TRUE, 84, 430, 376, 11, 260, 4.7, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq5/intro / 현대 국내 인증 대표값 / 오토데일리 기사: 아이오닉5 405km/354km 저온비율 적용', '2026-07-17', 'N은 84kWh·고성능 사양 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '중형 크로스오버', TRUE, 63, 367, 321, 11, 260, 5.2, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq5/intro / 현대 국내 인증 대표값 / 오토데일리 기사: 아이오닉5 롱레인지 RWD 405km/354km 비율 적용', '2026-07-17', 'N은 84kWh·고성능 사양 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 5' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'N AWD', '중형 세단', TRUE, 84, 400, 328, 11, 260, 4.3, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq6/intro / 현대 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '트림·휠에 따라 주행거리 차이 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 6' AND vt.trim_name = 'N AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 2WD 18인치', '중형 세단', TRUE, 84, 524, 428, 11, 260, 6.2, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq6/intro / 현대 국내 인증 대표값 / 환경부 공개 저온성능비율 78.6%와 국내 상온 524km 기준 환산(약 412km) / 브런치/환경부 자료 정리: 아이오닉6 롱레인지 2WD 18인치 상온 544km/저온 428km', '2026-07-17', '트림·휠에 따라 주행거리 차이 / 상온 주행거리·전비 공식 제원 반영 / 저온 복합 주행거리 반영 / 저온값 출처: 기사·환경부 자료 분석 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 2WD 18인치');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '롱레인지 AWD', '중형 세단', TRUE, 84, 494, 405, 11, 260, 5.5, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq6/intro / 현대 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '트림·휠에 따라 주행거리 차이 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '스탠다드 2WD', '중형 세단', TRUE, 63, 437, 358, 11, 260, 6.2, 18, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq6/intro / 현대 국내 인증 대표값 / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '트림·휠에 따라 주행거리 차이 / 상온 주행거리·전비 공식 제원 반영 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 6' AND vt.trim_name = '스탠다드 2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '2WD', '대형 SUV', TRUE, 110.3, 532, 436, 11, 350, 4.8, 24, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq9/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 9' AND vt.trim_name = '2WD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'AWD', '대형 SUV', TRUE, 110.3, 532, 436, 11, 350, 4.8, 24, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq9/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 9' AND vt.trim_name = 'AWD');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Performance', '대형 SUV', TRUE, 110.3, 532, 436, 11, 350, 4.8, 24, 'https://www.hyundai.com/kr/ko/e/vehicles/ioniq9/intro / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×82%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 9' AND vt.trim_name = 'Performance');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '28kWh', '준중형 해치백', FALSE, 38.3, 271, 206, 7.2, 50, 6.3, 54, 'https://www.hyundai.com/kr/ko / 현대차그룹 기사: 아이오닉 저온비율 약 76%', '2026-07-17', '초기 연식은 28kWh·191km급 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '28kWh');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, '38.3kWh', '준중형 해치백', FALSE, 38.3, 271, 206, 7.2, 50, 6.3, 54, 'https://www.hyundai.com/kr/ko / 현대차그룹 기사: 아이오닉 저온비율 약 76%', '2026-07-17', '초기 연식은 28kWh·191km급 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '38.3kWh');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Cross', '경형·소형 SUV', TRUE, 49, 315, 236, 11, 120, 5.6, 30, 'https://casper.hyundai.com/vehicles/electric / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Cross');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Inspiration', '경형·소형 SUV', TRUE, 49, 315, 236, 11, 120, 5.6, 30, 'https://casper.hyundai.com/vehicles/electric / 연합뉴스·전자신문 등 공개자료의 저온 감소폭(약 10~40%)과 브랜드/플랫폼별 기사 사례를 바탕으로 추정', '2026-07-17', '기술 사양 차이로 별도 행 분리 / 저온값 유형: 검색 기반 추정값(상온×75%), 공식 인증값 아님 / 급속 SOC 기준: 10→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Inspiration');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Long Range', '소형 SUV', FALSE, 64, 406, 365, 7.2, 100, 5.6, 54, 'https://www.hyundai.com/kr/ko / 현대차그룹 기사: 코나 일렉트릭 상온 대비 저온비율 약 90%', '2026-07-17', '연식·휠에 따라 수치 차이 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Long Range');

INSERT INTO vehicle_trim (model_id, trim_name, vehicle_type, is_current_sale, battery_kwh, normal_range_km, cold_range_km, max_ac_kw, max_dc_kw, efficiency_km_per_kwh, fast_charge_minutes, data_source, surveyed_at, note)
SELECT vm.model_id, 'Standard', '소형 SUV', FALSE, 64, 406, 365, 7.2, 100, 5.6, 54, 'https://www.hyundai.com/kr/ko / 현대차그룹 기사: 코나 일렉트릭 상온 대비 저온비율 약 90%', '2026-07-17', '연식·휠에 따라 수치 차이 / 저온값 유형: 기사 직접값 또는 기사 비율 환산 / 급속 SOC 기준: 0→80%'
FROM vehicle_model vm JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대'
  AND NOT EXISTS (
    SELECT 1 FROM vehicle_trim vt
    JOIN vehicle_model vm2 ON vm2.model_id = vt.model_id
    JOIN brand b2 ON b2.brand_id = vm2.brand_id
    WHERE b2.brand_name = '현대' AND vm2.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Standard');

-- 4) VEHICLE_CONNECTOR
INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '120Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '120Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '60Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '60Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '94Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = '94Ah'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = 'i3s'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i3' AND vt.trim_name = 'i3s'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'M50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'M50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'eDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'eDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i4' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'eDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'eDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i5' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'M70'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'M70'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'eDrive50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'eDrive50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'xDrive60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'i7' AND vt.trim_name = 'xDrive60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'M60'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'xDrive40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'xDrive50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX' AND vt.trim_name = 'xDrive50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1' AND vt.trim_name = 'eDrive20'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1' AND vt.trim_name = 'eDrive20'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1' AND vt.trim_name = 'xDrive30'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX1' AND vt.trim_name = 'xDrive30'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2' AND vt.trim_name = 'eDrive20'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2' AND vt.trim_name = 'eDrive20'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2' AND vt.trim_name = 'xDrive30'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX2' AND vt.trim_name = 'xDrive30'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX3' AND vt.trim_name = 'M Sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BMW' AND vm.model_name = 'iX3' AND vt.trim_name = 'M Sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3' AND vt.trim_name = 'Plus'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3' AND vt.trim_name = 'Plus'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'ATTO 3' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN Active'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'DOLPHIN' AND vt.trim_name = 'DOLPHIN Active'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEAL' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'BYD' AND vm.model_name = 'SEALION 7' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Opera'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Opera'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Rivoli'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'DS' AND vm.model_name = 'DS 3 E-TENSE' AND vt.trim_name = 'Rivoli'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV' AND vt.trim_name = '2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV' AND vt.trim_name = '2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV' AND vt.trim_name = '4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '무쏘 EV' AND vt.trim_name = '4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션' AND vt.trim_name = 'E3'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션' AND vt.trim_name = 'E3'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션' AND vt.trim_name = 'E5'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '코란도 이모션' AND vt.trim_name = 'E5'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX' AND vt.trim_name = 'E5'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX' AND vt.trim_name = 'E5'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX' AND vt.trim_name = 'E7'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'KGM' AND vm.model_name = '토레스 EVX' AND vt.trim_name = 'E7'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = 'MINI Electric' AND vt.trim_name = 'Cooper SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = 'MINI Electric' AND vt.trim_name = 'Cooper SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '뉴 MINI 쿠퍼 일렉트릭' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '에이스맨' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'E'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'JCW'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'SE ALL4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = 'MINI' AND vm.model_name = '컨트리맨 일렉트릭' AND vt.trim_name = 'SE ALL4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = 'GT-Line 롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = 'GT-Line 롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV3' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'GT-Line'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'GT-Line'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV4' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV5' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = 'GT AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = 'GT AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV6' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = '4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = '4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = 'GT AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = 'GT AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = 'GT-Line 4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = 'GT-Line 4WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = '롱레인지 2WD 19인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'EV9' AND vt.trim_name = '롱레인지 2WD 19인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5' AND vt.trim_name = 'Cargo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5' AND vt.trim_name = 'Cargo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5' AND vt.trim_name = 'Passenger'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = 'PV5' AND vt.trim_name = 'Passenger'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대' AND vt.trim_name = 'Noblesse'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대' AND vt.trim_name = 'Noblesse'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대' AND vt.trim_name = 'Prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '니로 EV 1세대' AND vt.trim_name = 'Prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '1인승 밴'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '1인승 밴'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '2인승 밴'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '2인승 밴'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '4인승'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '더 기아 레이 EV' AND vt.trim_name = '4인승'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Air'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Air'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Earth'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '디 올 뉴 니로 EV' AND vt.trim_name = 'Earth'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '레이 EV 1세대' AND vt.trim_name = '단일 트림'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '레이 EV 1세대' AND vt.trim_name = '단일 트림'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '봉고 III EV' AND vt.trim_name = '1톤 2WD 초장축'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '봉고 III EV' AND vt.trim_name = '1톤 2WD 초장축'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV' AND vt.trim_name = '18MY'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV' AND vt.trim_name = '18MY'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV' AND vt.trim_name = '19MY'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 EV' AND vt.trim_name = '19MY'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Noblesse'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Noblesse'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '기아' AND vm.model_name = '쏘울 부스터 EV' AND vt.trim_name = 'Prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프' AND vt.trim_name = '24kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프' AND vt.trim_name = '24kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프' AND vt.trim_name = '40kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '닛산' AND vm.model_name = '리프' AND vt.trim_name = '40kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = '450e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = '450e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = '550e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = '550e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = 'RZ 300e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'RZ' AND vt.trim_name = 'RZ 300e'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'UX 300e' AND vt.trim_name = 'Luxury'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '렉서스' AND vm.model_name = 'UX 300e' AND vt.trim_name = 'Luxury'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야' AND vt.trim_name = 'R'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야' AND vt.trim_name = 'R'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '에메야' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라' AND vt.trim_name = 'R'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라' AND vt.trim_name = 'R'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '로터스' AND vm.model_name = '엘레트라' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터' AND vt.trim_name = 'Black Badge'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터' AND vt.trim_name = 'Black Badge'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터' AND vt.trim_name = 'Spectre'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '롤스로이스' AND vm.model_name = '스펙터' AND vt.trim_name = 'Spectre'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.' AND vt.trim_name = 'RE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC3', 'AC', TRUE, 'DC 급속 미지원, AC 43kW 급속 전용'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.' AND vt.trim_name = 'RE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC3');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC3', 'AC', TRUE, 'DC 급속 미지원, AC 43kW 급속 전용'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = 'SM3 Z.E.' AND vt.trim_name = 'SE'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC3');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '세닉 E-Tech 일렉트릭' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '세닉 E-Tech 일렉트릭' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)' AND vt.trim_name = 'Intens'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)' AND vt.trim_name = 'Intens'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)' AND vt.trim_name = 'Zen'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '르노코리아' AND vm.model_name = '조에(ZOE)' AND vt.trim_name = 'Zen'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그란투리스모 폴고레' AND vt.trim_name = 'Folgore'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그란투리스모 폴고레' AND vt.trim_name = 'Folgore'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그레칼레 폴고레' AND vt.trim_name = 'Folgore'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '마세라티' AND vm.model_name = '그레칼레 폴고레' AND vt.trim_name = 'Folgore'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA' AND vt.trim_name = '250+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA' AND vt.trim_name = '250+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA' AND vt.trim_name = 'EQA 250'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQA' AND vt.trim_name = 'EQA 250'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQB' AND vt.trim_name = 'EQB 300 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQB' AND vt.trim_name = 'EQB 300 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQC' AND vt.trim_name = 'EQC 400 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQC' AND vt.trim_name = 'EQC 400 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = '350+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = '350+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = 'AMG 53'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = 'AMG 53'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = 'EQE 300'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE' AND vt.trim_name = 'EQE 300'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = '350 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = '350 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = '500'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = '500'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = 'AMG'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQE SUV' AND vt.trim_name = 'AMG'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = '450 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = '450 4MATIC'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = '450+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = '450+'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = 'AMG 53'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS' AND vt.trim_name = 'AMG 53'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = '450'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = '450'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = '580'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = '580'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = 'Maybach 680'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'EQS SUV' AND vt.trim_name = 'Maybach 680'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'G 580 with EQ Technology' AND vt.trim_name = 'G 580'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '메르세데스-벤츠' AND vm.model_name = 'G 580 with EQ Technology' AND vt.trim_name = 'G 580'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Twin Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'C40 Recharge / EC40' AND vt.trim_name = 'Twin Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'EX30' AND vt.trim_name = 'Single Motor Extended Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'EX30' AND vt.trim_name = 'Single Motor Extended Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Twin Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '볼보' AND vm.model_name = 'XC40 Recharge / EX40' AND vt.trim_name = 'Twin Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EUV' AND vt.trim_name = 'Premier'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EUV' AND vt.trim_name = 'Premier'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV' AND vt.trim_name = 'LT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV' AND vt.trim_name = 'LT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV' AND vt.trim_name = 'Premier'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '볼트 EV' AND vt.trim_name = 'Premier'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '스파크 EV' AND vt.trim_name = '단일 트림'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '쉐보레' AND vm.model_name = '스파크 EV' AND vt.trim_name = '단일 트림'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '45'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '45'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '50 quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 Sportback e-tron' AND vt.trim_name = '50 quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '40'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '45'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '45'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '50 quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q4 e-tron' AND vt.trim_name = '50 quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'SQ6'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'SQ6'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q6 e-tron' AND vt.trim_name = 'quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = 'SQ8'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'Q8 e-tron' AND vt.trim_name = 'SQ8'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron 50/55 quattro' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'RS'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'RS'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron GT' AND vt.trim_name = 'quattro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback' AND vt.trim_name = '50'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '아우디' AND vm.model_name = 'e-tron Sportback' AND vt.trim_name = '55'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '재규어' AND vm.model_name = 'I-PACE' AND vt.trim_name = 'EV400'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '재규어' AND vm.model_name = 'I-PACE' AND vt.trim_name = 'EV400'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified G80' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified G80' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified GV70' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'Electrified GV70' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '스탠다드 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '스탠다드 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '퍼포먼스 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '제네시스' AND vm.model_name = 'GV60' AND vt.trim_name = '퍼포먼스 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV' AND vt.trim_name = 'Altitude'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV' AND vt.trim_name = 'Altitude'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV' AND vt.trim_name = 'Summit'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '지프' AND vm.model_name = '어벤저 EV' AND vt.trim_name = 'Summit'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '캐딜락' AND vm.model_name = '리릭' AND vt.trim_name = 'Sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '캐딜락' AND vm.model_name = '리릭' AND vt.trim_name = 'Sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'Long Range AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'Long Range AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'Performance AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'Performance AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model 3' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S' AND vt.trim_name = 'Plaid'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model S' AND vt.trim_name = 'Plaid'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X' AND vt.trim_name = 'Plaid'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model X' AND vt.trim_name = 'Plaid'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'Long Range AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'Long Range AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'Performance AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'Performance AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'NACS', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'NACS');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', FALSE, 'CCS1 어댑터 사용 시'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '테슬라' AND vm.model_name = 'Model Y' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = '4S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = '4S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Macan 4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Macan 4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '마칸 일렉트릭' AND vt.trim_name = 'Turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = '4S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = '4S'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'Cross Turismo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'Cross Turismo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'RWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'Turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '포르쉐' AND vm.model_name = '타이칸' AND vt.trim_name = 'Turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4' AND vt.trim_name = 'Pro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4' AND vt.trim_name = 'Pro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4' AND vt.trim_name = 'Pro Lite'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.4' AND vt.trim_name = 'Pro Lite'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.5' AND vt.trim_name = 'Pro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폭스바겐' AND vm.model_name = 'ID.5' AND vt.trim_name = 'Pro'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 2' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4' AND vt.trim_name = 'Dual Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4' AND vt.trim_name = 'Dual Motor'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4' AND vt.trim_name = 'Long Range Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '폴스타' AND vm.model_name = 'Polestar 4' AND vt.trim_name = 'Long Range Single'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008' AND vt.trim_name = 'Allure'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008' AND vt.trim_name = 'Allure'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008' AND vt.trim_name = 'GT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-2008' AND vt.trim_name = 'GT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208' AND vt.trim_name = 'Allure'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208' AND vt.trim_name = 'Allure'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208' AND vt.trim_name = 'GT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '푸조' AND vm.model_name = 'e-208' AND vt.trim_name = 'GT'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '샤시캡'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '샤시캡'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '카고'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '카고'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '특장'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = 'ST1' AND vt.trim_name = '특장'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '롱레인지 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '디 올 뉴 코나 일렉트릭' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = 'N AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = 'N AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 2WD 19인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 2WD 19인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 5' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = 'N AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = 'N AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 2WD 18인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 2WD 18인치'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '롱레인지 AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 6' AND vt.trim_name = '스탠다드 2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = '2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = '2WD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = 'AWD'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = 'Performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 9' AND vt.trim_name = 'Performance'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '28kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, '연식별로 상이'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '28kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, '연식별로 상이'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '28kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '38.3kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_CHADEMO', 'DC', TRUE, '연식별로 상이'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '38.3kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_CHADEMO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, '연식별로 상이'
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '아이오닉 일렉트릭' AND vt.trim_name = '38.3kWh'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Cross'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Cross'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Inspiration'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '캐스퍼 일렉트릭' AND vt.trim_name = 'Inspiration'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Long Range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'AC_SLOW', 'AC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'AC_SLOW');

INSERT INTO vehicle_connector (vehicle_trim_id, connector_code, charge_mode, is_standard, note)
SELECT vt.vehicle_trim_id, 'DC_COMBO', 'DC', TRUE, NULL
FROM vehicle_trim vt
JOIN vehicle_model vm ON vm.model_id = vt.model_id
JOIN brand b ON b.brand_id = vm.brand_id
WHERE b.brand_name = '현대' AND vm.model_name = '코나 일렉트릭 1세대' AND vt.trim_name = 'Standard'
  AND NOT EXISTS (SELECT 1 FROM vehicle_connector vc
    WHERE vc.vehicle_trim_id = vt.vehicle_trim_id AND vc.connector_code = 'DC_COMBO');

