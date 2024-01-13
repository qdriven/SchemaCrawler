-- Triggers
-- Oracle syntax
CREATE TRIGGER TRG_Authors 
AFTER INSERT OR DELETE 
ON Authors 
FOR EACH ROW 
BEGIN
  UPDATE Publishers 
    SET Publisher = 'Jacob' 
    WHERE Publisher = 'John';
END;
