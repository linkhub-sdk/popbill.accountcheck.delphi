unit PopbillAccountCheck;

interface

uses
        TypInfo,SysUtils,Classes,
        Popbill, Linkhub;
type
        TAccountCheckChargeInfo = class
        public
                unitCost : string;
                chargeMethod : string;
                rateSystem : string;
        end;
        
        TAccountCheckInfo = class
        public
                bankCode : string;
                accountNumber : string;
                accountName : string;
                checkDate : Double;
                resultCode : string;
                result : string;
                resultMessage : string;
        end;

        TDepositorCheckInfo = class
        public
                bankCode : string;
                accountNumber : string;
                accountName : string;
                checkDate : Double;
                identityNumType : string;
                identityNum : string;
                result : string;
                resultMessage : string;
        end;

        TAccountCheckService = class(TPopbillBaseService)
        private
                function jsonToTAccountCheckInfo(json : String) : TAccountCheckInfo;
                function jsonToTDepositorCheckInfo(json : String) : TDepositorCheckInfo;

        public
                constructor Create(LinkID : String; SecretKey : String);
                function GetUnitCost(CorpNum : String): Single; overload;
                function GetUnitCost(CorpNum : String; ServiceType : String; UserID : String = ''): Single; overload;
                function CheckAccountInfo(CorpNum : String; BankCode : String; AccountNumber : String; UserID : String = '') : TAccountCheckInfo;
                function CheckDepositorInfo(CorpNum : String; BankCode : String; AccountNumber : String; IdentityNumType : String; IdentityNum : String; UserID : String = '') : TDepositorCheckInfo;
                function GetChargeInfo(CorpNum : String) : TAccountCheckChargeInfo; overload;
                function GetChargeInfo(CorpNum : String; ServiceType : String; UserID : String = '') : TAccountCheckChargeInfo; overload;
        end;


implementation

constructor TAccountCheckService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('182');
       AddScope('183');
end;

function UrlEncodeUTF8(stInput : widestring) : string;
  const
    hex : array[0..255] of string = (
     '%00', '%01', '%02', '%03', '%04', '%05', '%06', '%07',
     '%08', '%09', '%0a', '%0b', '%0c', '%0d', '%0e', '%0f',
     '%10', '%11', '%12', '%13', '%14', '%15', '%16', '%17',
     '%18', '%19', '%1a', '%1b', '%1c', '%1d', '%1e', '%1f',
     '%20', '%21', '%22', '%23', '%24', '%25', '%26', '%27',
     '%28', '%29', '%2a', '%2b', '%2c', '%2d', '%2e', '%2f',
     '%30', '%31', '%32', '%33', '%34', '%35', '%36', '%37',
     '%38', '%39', '%3a', '%3b', '%3c', '%3d', '%3e', '%3f',
     '%40', '%41', '%42', '%43', '%44', '%45', '%46', '%47',
     '%48', '%49', '%4a', '%4b', '%4c', '%4d', '%4e', '%4f',
     '%50', '%51', '%52', '%53', '%54', '%55', '%56', '%57',
     '%58', '%59', '%5a', '%5b', '%5c', '%5d', '%5e', '%5f',
     '%60', '%61', '%62', '%63', '%64', '%65', '%66', '%67',
     '%68', '%69', '%6a', '%6b', '%6c', '%6d', '%6e', '%6f',
     '%70', '%71', '%72', '%73', '%74', '%75', '%76', '%77',
     '%78', '%79', '%7a', '%7b', '%7c', '%7d', '%7e', '%7f',
     '%80', '%81', '%82', '%83', '%84', '%85', '%86', '%87',
     '%88', '%89', '%8a', '%8b', '%8c', '%8d', '%8e', '%8f',
     '%90', '%91', '%92', '%93', '%94', '%95', '%96', '%97',
     '%98', '%99', '%9a', '%9b', '%9c', '%9d', '%9e', '%9f',
     '%a0', '%a1', '%a2', '%a3', '%a4', '%a5', '%a6', '%a7',
     '%a8', '%a9', '%aa', '%ab', '%ac', '%ad', '%ae', '%af',
     '%b0', '%b1', '%b2', '%b3', '%b4', '%b5', '%b6', '%b7',
     '%b8', '%b9', '%ba', '%bb', '%bc', '%bd', '%be', '%bf',
     '%c0', '%c1', '%c2', '%c3', '%c4', '%c5', '%c6', '%c7',
     '%c8', '%c9', '%ca', '%cb', '%cc', '%cd', '%ce', '%cf',
     '%d0', '%d1', '%d2', '%d3', '%d4', '%d5', '%d6', '%d7',
     '%d8', '%d9', '%da', '%db', '%dc', '%dd', '%de', '%df',
     '%e0', '%e1', '%e2', '%e3', '%e4', '%e5', '%e6', '%e7',
     '%e8', '%e9', '%ea', '%eb', '%ec', '%ed', '%ee', '%ef',
     '%f0', '%f1', '%f2', '%f3', '%f4', '%f5', '%f6', '%f7',
     '%f8', '%f9', '%fa', '%fb', '%fc', '%fd', '%fe', '%ff');
 var
   iLen,iIndex : integer;
   stEncoded : string;
   ch : widechar;
 begin
   iLen := Length(stInput);
   stEncoded := '';
   for iIndex := 1 to iLen do
   begin
     ch := stInput[iIndex];
     if (ch >= 'A') and (ch <= 'Z') then
       stEncoded := stEncoded + ch
     else if (ch >= 'a') and (ch <= 'z') then
       stEncoded := stEncoded + ch
     else if (ch >= '0') and (ch <= '9') then
       stEncoded := stEncoded + ch
     else if (ch = ' ') then
       stEncoded := stEncoded + '+'
     else if ((ch = '-') or (ch = '_') or (ch = '.') or (ch = '!') or (ch = '*')
       or (ch = '~') or (ch = '\')  or (ch = '(') or (ch = ')')) then
       stEncoded := stEncoded + ch
     else if (Ord(ch) <= $07F) then
       stEncoded := stEncoded + hex[Ord(ch)]
     else if (Ord(ch) <= $7FF) then
     begin
        stEncoded := stEncoded + hex[$c0 or (Ord(ch) shr 6)];
        stEncoded := stEncoded + hex[$80 or (Ord(ch) and $3F)];
     end
     else
     begin
        stEncoded := stEncoded + hex[$e0 or (Ord(ch) shr 12)];
        stEncoded := stEncoded + hex[$80 or ((Ord(ch) shr 6) and ($3F))];
        stEncoded := stEncoded + hex[$80 or ((Ord(ch)) and ($3F))];
     end;
   end;
   result := (stEncoded);
 end;

function TAccountCheckService.GetUnitCost(CorpNum : String) : Single;
begin
        result := GetUnitCost(CorpNum, '', '');
end;

function TAccountCheckService.GetUnitCost(CorpNum : String; ServiceType : String; UserID : String = '') : Single;
var
        responseJson : string;
begin
        try
                responseJson := httpget('/EasyFin/AccountCheck/UnitCost?serviceType='+UrlEncodeUTF8(ServiceType),CorpNum,UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code, le.message);
                                exit;
                        end
                        else
                        begin
                                result := 0.0;
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := 0.0;
                exit;
        end
        else
        begin
                result := strToFloat(getJSonString( responseJson,'unitCost'));
        end;
end;

function TAccountCheckService.GetChargeInfo(CorpNum : String) : TAccountCheckChargeInfo;
begin
        result := GetChargeInfo(CorpNum, '', '');
end;

function TAccountCheckService.GetChargeInfo(CorpNum : String; ServiceType : String; UserID : String = '') : TAccountCheckChargeInfo;
var
        responseJson : String;
begin
        try
                responseJson := httpget('/EasyFin/AccountCheck/ChargeInfo?serviceType='+UrlEncodeUTF8(ServiceType),CorpNum,UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end
                        else
                        begin
                                result := TAccountCheckChargeInfo.Create;
                                setLastErrCode(le.code);
                                setLastErrMessage(le.message);
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := TAccountCheckChargeInfo.Create;
                exit;
        end
        else
        begin
                try
                        result := TAccountCheckChargeInfo.Create;
                        result.unitCost := getJSonString(responseJson, 'unitCost');
                        result.chargeMethod := getJSonString(responseJson, 'chargeMethod');
                        result.rateSystem := getJSonString(responseJson, 'rateSystem');
                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        result := TAccountCheckChargeInfo.Create;
                                        setLastErrCode(-99999999);
                                        setLastErrMessage('결과처리 실패.[Malformed Json]');
                                        exit;
                                end;
                        end;
                end;
        end;
end;


function TAccountCheckService.jsonToTAccountCheckInfo(json : String) : TAccountCheckInfo;
begin
        result := TAccountCheckInfo.Create;

        if Length(getJsonString(json, 'resultCode')) > 0 then
        begin
                result.resultCode := getJsonString(json, 'resultCode');
        end;

        if Length(getJsonString(json, 'result')) > 0 then
        begin
                result.result := getJsonString(json, 'result');
        end;

        if Length(getJsonString(json, 'resultMessage')) > 0  then
        begin
                result.resultMessage := getJsonString(json, 'resultMessage');
        end;

        if Length(getJsonString(json, 'bankCode')) > 0 then
        begin
                result.bankCode := getJsonString(json, 'bankCode');
        end;

        if Length(getJsonString(json, 'accountNumber')) > 0  then
        begin
               result.accountNumber := getJsonString(json, 'accountNumber');
        end;

        if Length(getJsonString(json, 'accountName')) > 0 then
        begin
              result.accountName := getJsonString(json, 'accountName');
        end;

        if Length(getJsonString(json, 'checkDate')) > 0 then
        begin
              result.checkDate := getJSonFloat(json, 'checkDate');
        end;        
end;


function TAccountCheckService.CheckAccountInfo(CorpNum:string; BankCode:String; AccountNumber:string; UserID: string = '') : TAccountCheckInfo;
var
        responseJson : string;
begin

        try
                responseJson := httppost('/EasyFin/AccountCheck?c='+BankCode+'&&n='+AccountNumber, CorpNum, UserID, '', '');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                                exit;
                        end
                        else
                        begin
                                result := TAccountCheckInfo.Create;
                                exit;
                        end;
                end;
        end;
        
        if LastErrCode <> 0 then
        begin
                result := TAccountCheckInfo.Create;
                exit;
        end
        else
        begin
                result := jsonToTAccountCheckInfo(responseJson);
        end;

end;

function TAccountCheckService.jsonToTDepositorCheckInfo(json : String) : TDepositorCheckInfo;
begin
        result := TDepositorCheckInfo.Create;

        if Length(getJsonString(json, 'result')) > 0 then
        begin
                result.result := getJsonString(json, 'result');
        end;

        if Length(getJsonString(json, 'resultMessage')) > 0  then
        begin
                result.resultMessage := getJsonString(json, 'resultMessage');
        end;

        if Length(getJsonString(json, 'bankCode')) > 0 then
        begin
                result.bankCode := getJsonString(json, 'bankCode');
        end;

        if Length(getJsonString(json, 'accountNumber')) > 0  then
        begin
               result.accountNumber := getJsonString(json, 'accountNumber');
        end;

        if Length(getJsonString(json, 'accountName')) > 0 then
        begin
              result.accountName := getJsonString(json, 'accountName');
        end;

        if Length(getJsonString(json, 'checkDate')) > 0 then
        begin
              result.checkDate := getJSonFloat(json, 'checkDate');
        end;

        if Length(getJsonString(json, 'identityNumType')) > 0 then
        begin
              result.identityNumType := getJsonString(json, 'identityNumType');
        end;

        if Length(getJsonString(json, 'identityNum')) > 0 then
        begin
              result.identityNum := getJsonString(json, 'identityNum');
        end;
end;

function TAccountCheckService.CheckDepositorInfo(CorpNum : String; BankCode : String; AccountNumber : String; IdentityNumType : String; IdentityNum : String; UserID : String = '') : TDepositorCheckInfo;
var
        uri : string;
        responseJson : string;
begin
        try
                uri := '/EasyFin/DepositorCheck?c='+BankCode+'&&n='+AccountNumber+'&&t='+IdentityNumType+'&&p='+IdentityNum;
                responseJson := httppost(uri, CorpNum, UserID, '', '');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                                exit;
                        end
                        else
                        begin
                                result := TDepositorCheckInfo.Create;
                                exit;
                        end;
                end;
        end;
        
        if LastErrCode <> 0 then
        begin
                result := TDepositorCheckInfo.Create;
                exit;
        end
        else
        begin
                result := jsonToTDepositorCheckInfo(responseJson);
        end;

end;

end.