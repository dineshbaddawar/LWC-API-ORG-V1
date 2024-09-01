/**
 * @author [Dinesh Baddawar]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2024-03-11 17:34:46
 * @modify date 2024-03-11 17:34:46
 * @desc [description]
 */


public class OutlookIntegration {
    
    
    public PageReference Outlookresponse(){
        String code = ApexPages.currentPage().getParameters().get('code');
        system.debug('code =====> ' + code);
        if (code != null){
            System.debug(' Iam authorization flow');
        }
        return null;
    }
    
    @future(callout = true)
    public Static void GenerateEventLinkwithNewFlow(String Email, String Subject, String Timings, String meetDate, String timezone){
        System.debug(' Timings  == >' + Timings + ' && meetDate == >' + meetDate);
        try{
            system.debug('Timings == > ' + Timings + ' &&  meetDate ==> ' + meetDate);
            string startTime = Timings.substring(0, 2);
            String EndeTime = Timings.substring(6, 8);
            
            OutlookeventCreatingWrapper newWapper = new OutlookeventCreatingWrapper();
            
            newWapper.subject = Subject;
            
            OutlookeventCreatingWrapper.body bd = new OutlookeventCreatingWrapper.body();
            bd.content = Subject;
            bd.contentType = 'HTML';
            
            OutlookeventCreatingWrapper.start st = new OutlookeventCreatingWrapper.start();
            st.timeZone = timezone; //pass meter ===>old vlaue : Pacific Standard Time
            st.dateTimes = meetDate + 'T' + startTime + ':00:00';//'2019-03-15T14:00:00';
            
            OutlookeventCreatingWrapper.location nt = new OutlookeventCreatingWrapper.location();
            nt.displayName = 'Ecolibrium';
            
            OutlookeventCreatingWrapper.ends ed = new OutlookeventCreatingWrapper.ends();
            ed.timeZone = timezone;// pass meter
            ed.dateTimes = meetDate + 'T' + EndeTime + ':00:00';//'2019-03-15T15:00:00';
            
            List<OutlookeventCreatingWrapper.attendees> attList = new List<OutlookeventCreatingWrapper.attendees>();
            
            List<String> EmailList = new List<String>();
            
            if (Email != '' && Email != null){
                EmailList = Email.split(',', 0);
            }
            system.debug('EmailList === >' + EmailList);
            map<string, String> Emailbyname = new map<string, String>();
            
            List<Lead> LeadList = [select id, name, Email from Lead where email in:EmailList];
            
            for (Lead led : LeadList){
                Emailbyname.put(led.name, led.Email);
            }
            
            for (String abc : EmailList){
                OutlookeventCreatingWrapper.emailAddress ea = new OutlookeventCreatingWrapper.emailAddress();
                ea.address = abc;
                ea.name = abc;
                OutlookeventCreatingWrapper.attendees att = new OutlookeventCreatingWrapper.attendees();
                att.emailAddress = ea;
                att.type = 'required';
                attList.add(att);
            }
            
            newWapper.body = bd;
            newWapper.start = st;
            newWapper.ends = ed;
            newWapper.location = nt;
            newWapper.attendees = attList;
            
            newWapper.allowNewTimeProposals = true;
            newWapper.isOnlineMeeting = true;
            newWapper.onlineMeetingProvider = 'teamsForBusiness';
            Integer randomNumber = Integer.valueof((Math.random() * 10));
            Integer randomNumber1 = Integer.valueof((Math.random() * 1000));
            newWapper.transactionId = '7E' + randomNumber + '3156-' + randomNumber1 + '-4BEB-A1C6-729EA807' + randomNumber + 'A7';
            
            string jsonString = JSON.serialize(newWapper);
            
            jsonString = jsonString.replace('ends', 'end');
            jsonString = jsonString.replace('dateTimes', 'dateTime');
            
            System.debug('jsonString >> ' + jsonString);
            
            String eventLink = OutlookIntegration.createeventwithNewFlow(jsonString);
            
            System.debug('eventLink >> ' + eventLink);
        } catch (Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
    }
    
    public static String GenerateAccesstokenwithNewFlow(){
        String ADtenentId = '9d94cb2f-05ce-4ac3-96a0-8a8a97437d2a';
        String endpoint = 'https://login.microsoftonline.com/' + ADtenentId + '/oauth2/v2.0/token';
        String clientId =System.label.OutllokclientId; //'f8de9f6c-0412-4fa6-8476-8458d3202e97';
        String clientSecret =System.label.OutllokclientSecret; //'3py8Q~DB7X0G5v4W_rKXzLxbIiF_Z4uQM_9w-akK';
        String scope = 'https://graph.microsoft.com/.default';
        String redirectUri = 'https://ecolibrium--dev--c.sandbox.vf.force.com/apex/OutlookintegrationPage';
        String authtype = 'authorization_code';
        
        String Body = 'client_id=' + clientId + '&scope=' + scope  + '&client_secret=' + clientSecret + '&grant_type=client_credentials';
        System.debug('Body ====> ' + Body);
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(Body);
        Http http = new Http();
        HTTPResponse res;
        try{
            res = http.send(request);
            JsonParser respWrapObj = JsonParser.parse(res.getBody());
            System.debug('respWrapObj === >' + respWrapObj);
            system.debug('access ===> ' + respWrapObj.access_token);
            return respWrapObj.access_token;
        } catch (Exception e){
            system.debug('exception::' + e.getMessage() + e.getLineNumber());
            return 'ERROR';
        }
    }
    
    public static String createeventwithNewFlow(String jasonString){
        String UserObjectId = '';
        String returnvalue = '';
        try{
            System.debug('jason String Generate Event >> ' + jasonString);
            string endPoint = 'https://graph.microsoft.com/v1.0/users/' + UserInfo.getUserEmail() + '/calendar/events'; //dabebf80-a217-46c7-a7cf-9aabe0f59f4d
            String accToken = OutlookIntegration.GenerateAccesstokenwithNewFlow();
            System.debug('accToken === >' + accToken);
            HttpRequest req = new HttpRequest();
            req.setBody(jasonString);
            req.setHeader('Accept', 'application/json');
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setEndpoint(endPoint);
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 201 || res.getStatusCode() == 200){
                outlookEventResponse respWrapObj = outlookEventResponse.parse(res.getBody());
                System.debug('respWrapObj createevent == >' + respWrapObj);
                System.debug('Meeting Link ====> ' + respWrapObj.webLink);
                returnvalue = respWrapObj.webLink;
            } else{
                System.debug('res fail >>> ' + res.getStatusCode() + ' && body >> ' + res.getBody());
                returnvalue = 'Fail';
            }
        } catch (Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
            return null;
        }
        return returnvalue;
    }
    
}