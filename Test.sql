USE [master]
GO
/****** Object:  Database [TestDB]    Script Date: 2023. 03. 17. 14:09:28 ******/
CREATE DATABASE [TestDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\TestDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TestDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\TestDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [TestDB] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TestDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TestDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TestDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TestDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TestDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TestDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [TestDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TestDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TestDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TestDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TestDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TestDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TestDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TestDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TestDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TestDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [TestDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TestDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TestDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TestDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TestDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TestDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TestDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TestDB] SET RECOVERY FULL 
GO
ALTER DATABASE [TestDB] SET  MULTI_USER 
GO
ALTER DATABASE [TestDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TestDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TestDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TestDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TestDB] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'TestDB', N'ON'
GO
ALTER DATABASE [TestDB] SET QUERY_STORE = OFF
GO
USE [TestDB]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [TestDB]
GO
/****** Object:  UserDefinedFunction [dbo].[ChkValidEmail]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ChkValidEmail](@EMAIL varchar(100))RETURNS bit as
BEGIN     
  DECLARE @bitEmailVal as Bit
  DECLARE @EmailText varchar(100)

  SET @EmailText=ltrim(rtrim(isnull(@EMAIL,'')))

  SET @bitEmailVal = case 
                          when @EmailText like ('%["(),:<>\]%') then 0
                          when substring(@EmailText,charindex('@',@EmailText),len(@EmailText)) like ('%[!#$%&*+/=?^`_{|]%') then 0
                          when (left(@EmailText,1) like ('[-_.+]') or right(@EmailText,1) like ('[-_.+]')) then 0                                                                                    
                          when (@EmailText like '%[%' or @EmailText like '%]%') then 0
						  when @EmailText NOT LIKE '_%@_%._%'  then 0
                          else 1 
                      end
  RETURN @bitEmailVal
END 
GO
/****** Object:  UserDefinedFunction [dbo].[extract]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[extract]
(
    @input nvarchar(500)
)
RETURNS nvarchar(100)
AS
BEGIN
    DECLARE @atPosition int
    DECLARE @firstRelevantSpace int
    DECLARE @name nvarchar(100)
    DECLARE @secondRelelvantSpace int
    DECLARE @everythingAfterAt nvarchar(500)
    DECLARE @domain nvarchar(100)
    DECLARE @email nvarchar(100) = ''
    IF CHARINDEX('@', @input,0) > 0
    BEGIN
        SET @input = ' ' + @input
        SET @atPosition = CHARINDEX('@', @input, 0)
        SET @firstRelevantSpace = CHARINDEX(' ',REVERSE(LEFT(@input, CHARINDEX('@', @input, 0) - 1)))
        SET @name = REVERSE(LEFT(REVERSE(LEFT(@input, @atPosition - 1)),@firstRelevantSpace-1))
        SET @everythingAfterAt = SUBSTRING(@input, @atPosition,len(@input)-@atPosition+1)
        SET @secondRelelvantSpace = CHARINDEX(' ',@everythingAfterAt)
        IF @secondRelelvantSpace = 0
            SET @domain = @everythingAfterAt
        ELSE
            SET @domain = LEFT(@everythingAfterAt, @secondRelelvantSpace)
        SET @email = @name + @domain
    END
    RETURN @email
END
GO
/****** Object:  UserDefinedFunction [dbo].[extractEmail]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[extractEmail]
(
    @input nvarchar(500)
)
RETURNS nvarchar(100)
AS
BEGIN
    DECLARE @atPosition int
    DECLARE @firstRelevantSpace int
    DECLARE @name nvarchar(100)
    DECLARE @secondRelelvantSpace int
    DECLARE @everythingAfterAt nvarchar(500)
    DECLARE @domain nvarchar(100)
    DECLARE @email nvarchar(100) = ''
    IF CHARINDEX('@', @input,0) > 0
    BEGIN
        SET @input = ' ' + @input
        SET @atPosition = CHARINDEX('@', @input, 0)
        SET @firstRelevantSpace = CHARINDEX(' ',REVERSE(LEFT(@input, CHARINDEX('@', @input, 0) - 1)))
        SET @name = REVERSE(LEFT(REVERSE(LEFT(@input, @atPosition - 1)),@firstRelevantSpace-1))
        SET @everythingAfterAt = SUBSTRING(@input, @atPosition,len(@input)-@atPosition+1)
        SET @secondRelelvantSpace = CHARINDEX(' ',@everythingAfterAt)
        IF @secondRelelvantSpace = 0
            SET @domain = @everythingAfterAt
        ELSE
            SET @domain = LEFT(@everythingAfterAt, @secondRelelvantSpace)
        SET @email = @name + @domain
    END
    RETURN @email
END
GO
/****** Object:  UserDefinedFunction [dbo].[splitstring]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[splitstring] ( @stringToSplit VARCHAR(MAX) )
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(';', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(';', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnFindPatternLocation]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnFindPatternLocation]
(
    @string NVARCHAR(MAX),
    @term   NVARCHAR(255)
)
RETURNS TABLE
AS
    RETURN 
    (
        SELECT pos = Number - LEN(@term) 
        FROM (SELECT Number, Item = LTRIM(RTRIM(SUBSTRING(@string, Number, 
        CHARINDEX(@term, @string + @term, Number) - Number)))
        FROM (SELECT ROW_NUMBER() OVER (ORDER BY [object_id])
        FROM sys.all_objects) AS n(Number)
        WHERE Number > 1 AND Number <= CONVERT(INT, LEN(@string))
        AND SUBSTRING(@term + @string, Number, LEN(@term)) = @term
    ) AS y);
GO
/****** Object:  Table [dbo].[Sample_email_list]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sample_email_list](
	[Path] [nvarchar](100) NOT NULL,
	[Locale] [nvarchar](50) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[ExtensionSettings] [nvarchar](850) NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[EventType] [nvarchar](50) NOT NULL,
	[Type_of_subscription] [nvarchar](50) NOT NULL,
	[LastRunTime] [datetime2](7) NOT NULL,
	[DeliveryExtension] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sample_test]    Script Date: 2023. 03. 17. 14:09:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sample_test](
	[column1] [nvarchar](50) NOT NULL,
	[column2] [nvarchar](1800) NOT NULL
) ON [PRIMARY]
GO
USE [master]
GO
ALTER DATABASE [TestDB] SET  READ_WRITE 
GO
