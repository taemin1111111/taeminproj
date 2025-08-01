-- wishlist 테이블에 personal_note 컬럼 추가
ALTER TABLE wishlist ADD COLUMN personal_note TEXT NULL COMMENT '개인 메모';

-- 기존 데이터의 personal_note를 NULL로 설정 (이미 NULL이지만 명시적으로 설정)
UPDATE wishlist SET personal_note = NULL WHERE personal_note IS NULL; 