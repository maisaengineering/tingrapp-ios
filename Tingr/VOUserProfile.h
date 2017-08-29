
#import <Foundation/Foundation.h>

@interface UserProfile : NSObject
{
    NSString *auth_token;
    NSString *kl_id;
    NSString *fname;
    NSString *mname;
    NSString *lname;
    NSString *email;
    NSArray  *phone_numbers;
    NSArray  *organizations;
    NSString *verified_phone_number;
    NSString *photograph;
    // added one bool
    BOOL     onboarding;
    //
    NSMutableDictionary *onboarding_partner;
    NSString *country_code;
    NSString *onboarding_tour;
    
}

@property (strong, nonatomic) NSString *auth_token;
@property (strong, nonatomic) NSString *kl_id;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *mname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray  *phone_numbers;
@property (strong, nonatomic) NSArray  *organizations;
@property (nonatomic)         BOOL      onboarding;
@property (strong, nonatomic) NSString *onboarding_tour;
@property (strong, nonatomic) NSString *country_code;
 @property (strong, nonatomic) NSMutableDictionary *onboarding_partner;
@property (nonatomic, strong)     NSString *verified_phone_number;
@property (nonatomic)     BOOL i_am_sharing_documents_to;
@property (nonatomic)     BOOL is_kidslink_user;
@property (nonatomic)     BOOL sharing_documents_with_me;
@property (nonatomic)     int ios_tab;
@property (nonatomic) BOOL isNewUser;
@property (nonatomic, assign) BOOL isKidsLinkPersonality;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) BOOL isight_enabled;
@property (nonatomic, strong) NSString *photograph;
@end
