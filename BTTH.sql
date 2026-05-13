-- ================================
-- TẠO DATABASE
-- ================================

CREATE DATABASE IF NOT EXISTS clinic_management;
USE clinic_management;

-- ================================
-- XÓA BẢNG CŨ NẾU ĐÃ TỒN TẠI
-- ================================

DROP TABLE IF EXISTS Patient_Invoices;
DROP TABLE IF EXISTS Medicines;

-- ================================
-- TẠO BẢNG MEDICINES
-- ================================

CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

-- ================================
-- TẠO BẢNG PATIENT_INVOICES
-- ================================

CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(10,2) DEFAULT 0
);

-- ================================
-- CHÈN DỮ LIỆU MẪU
-- ================================

INSERT INTO Medicines VALUES
(1, 'Paracetamol', 10000, 50),
(2, 'Vitamin C', 20000, 20),
(3, 'Antibiotic', 50000, 5);

INSERT INTO Patient_Invoices VALUES
(101, 0),
(102, 0),
(103, 0);

-- ================================
-- XÓA PROCEDURE CŨ NẾU ĐÃ TỒN TẠI
-- ================================

DROP PROCEDURE IF EXISTS ProcessPrescription;

-- ================================
-- TẠO STORED PROCEDURE
-- ================================

DELIMITER $$

CREATE PROCEDURE ProcessPrescription(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    IN p_discount_code VARCHAR(50),
    OUT p_message VARCHAR(255)
)

BEGIN

    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_final_total DECIMAL(10,2);

    -- ============================
    -- KIỂM TRA SỐ LƯỢNG HỢP LỆ
    -- ============================

    IF p_quantity <= 0 THEN

        SET p_message = 'Thất bại: Số lượng không hợp lệ';

    ELSE

        -- ============================
        -- LẤY GIÁ THUỐC & TỒN KHO
        -- ============================

        SELECT price, stock
        INTO v_price, v_stock
        FROM Medicines
        WHERE medicine_id = p_medicine_id;

        -- ============================
        -- KIỂM TRA TỒN KHO
        -- ============================

        IF v_stock < p_quantity THEN

            SET p_message = 'Thất bại: Kho không đủ thuốc';

        ELSE

            -- ============================
            -- TRỪ KHO
            -- ============================

            UPDATE Medicines
            SET stock = stock - p_quantity
            WHERE medicine_id = p_medicine_id;

            -- ============================
            -- TÍNH TIỀN GỐC
            -- ============================

            SET v_total = p_quantity * v_price;

            -- ============================
            -- ÁP DỤNG MÃ GIẢM GIÁ
            -- ============================

            IF p_discount_code = 'NV-RIKKEI' THEN

                SET v_final_total = v_total * 0.5;

            ELSE

                SET v_final_total = v_total;

            END IF;

            -- ============================
            -- CẬP NHẬT TỔNG NỢ
            -- ============================

            UPDATE Patient_Invoices
            SET total_due = total_due + v_final_total
            WHERE patient_id = p_patient_id;

            -- ============================
            -- THÔNG BÁO THÀNH CÔNG
            -- ============================

            SET p_message = 'Thành công: Đã xử lý đơn thuốc';

        END IF;

    END IF;

END $$

DELIMITER ;

-- ================================
-- KIỂM THỬ 1
-- KÊ ĐƠN BÌNH THƯỜNG
-- ================================

CALL ProcessPrescription(
    101,
    1,
    2,
    NULL,
    @msg1
);

SELECT @msg1;

-- ================================
-- KIỂM THỬ 2
-- CÓ MÃ GIẢM GIÁ NV-RIKKEI
-- ================================

CALL ProcessPrescription(
    102,
    2,
    4,
    'NV-RIKKEI',
    @msg2
);

SELECT @msg2;

-- ================================
-- KIỂM THỬ 3
-- VƯỢT QUÁ TỒN KHO
-- ================================

CALL ProcessPrescription(
    103,
    3,
    10,
    NULL,
    @msg3
);

SELECT @msg3;

-- ================================
-- XEM KẾT QUẢ CUỐI
-- ================================

SELECT * FROM Medicines;

SELECT * FROM Patient_Invoices;