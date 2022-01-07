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
                function GetUnitCost(CorpNum : String): Single;
                function CheckAccountInfo(CorpNum : String; BankCode : String; AccountNumber : String; UserID : String = '') : TAccountCheckInfo;
                function CheckDepositorInfo(CorpNum : String; BankCode : String; AccountNumber : String; IdentityNumType : String; IdentityNum : String; UserID : String = '') : TDepositorCheckInfo;
                function GetChargeInfo(CorpNum : String) : TAccountCheckChargeInfo;
        end;


implementation

constructor TAccountCheckService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('182');
       AddScope('183');
end;

function TAccountCheckService.GetUnitCost(CorpNum : String) : Single;
var
        responseJson : string;
begin
        try
                responseJson := httpget('/EasyFin/AccountCheck/UnitCost',CorpNum,'');
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


function TAccountCheckService.GetChargeInfo(CorpNum : string) : TAccountCheckChargeInfo;
var
        responseJson : String;
begin
        try
                responseJson := httpget('/EasyFin/AccountCheck/ChargeInfo',CorpNum,'');
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