DECLARE @Result INT;
EXEC Wiki_DeleteGuide @GuideID = 24, @UserID = 3982, @Result = @Result OUTPUT;
SELECT @Result AS DeleteResult;
SELECT COUNT(*) AS Remaining FROM WikiPlayerGuide WHERE GuideID = 24;
