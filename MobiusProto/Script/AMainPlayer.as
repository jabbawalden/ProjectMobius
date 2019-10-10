import UWidgetScore;
import AMobiusGameMode;
import UWidgetHealth;

class AMainPlayer : APawn
{
    AMobiusGameMode GameMode; 

    UPROPERTY(DefaultComponent, RootComponent)
    UBoxComponent BoxCollision;
    default BoxCollision.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    default BoxCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
    default BoxCollision.SetCollisionObjectType(ECollisionChannel::ECC_Pawn);

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UStaticMeshComponent MeshComp;
    default MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    USceneComponent FireOrigin;

    UPROPERTY()
    TSubclassOf<AActor> ProjectileType;
    AActor ProjectileRef;

    UPROPERTY()
    TSubclassOf<UWidgetScore> WidgetClassScore;
    UPROPERTY()
    TSubclassOf<UWidgetHealth> WidgetClassHealth;

    bool CanFire = false;

    float NextFire;
    float FireRate = 0.1f;

    UPROPERTY(DefaultComponent)
    UInputComponent InputComp;

    UPROPERTY()
    float MovementSpeed = 3000;

    int MaxHealth = 3;
    int Health;

    UPROPERTY(DefaultComponent)
    UFloatingPawnMovement FloatingPawnMovement;
    default FloatingPawnMovement.MaxSpeed = MovementSpeed;
    default FloatingPawnMovement.Acceleration = MovementSpeed * 10;
    default FloatingPawnMovement.Deceleration = MovementSpeed * 10;

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    USpringArmComponent SpringArm;
    default SpringArm.TargetArmLength = 1750;  

    UPROPERTY(DefaultComponent, Attach = SpringArm)
    UCameraComponent MainCamera;

    bool IsAlive = true;
    bool CannotMove = false;

    float Ypos1 = -888.0;
    float Ypos2 = -288.0;
    float Ypos3 = 312.0;
    float Ypos4 = 912.0;


    int CurrentYPosition = 2;

    float NewMoveTime = 0;
    float MoveRate = 0.23;

    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {
        SpringArm.SetRelativeRotation(FRotator(-25, 0, 0));
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Health = MaxHealth;
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());
        // MovementSpeed = GameMode.PlayerSpeed;
        // GameMode.EventSpeedIncrease.AddUFunction(this, n"UpdateMovementSpeed");

        PlayerInputSetup();
        APlayerController PlayerController = Gameplay::GetPlayerController(0);

        AddScoreWidgetToHUD(PlayerController, WidgetClassScore);
        AddHealthWidgetToHUD(PlayerController, WidgetClassHealth);

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds) 
    {
        if (IsAlive)
        {
            HandleFiring();
            HandleYMovement();
        }

    }

    UFUNCTION()
    void HandleFiring()
    {
        if (CanFire)
        {
            if (NextFire <= Gameplay::TimeSeconds)
            {
                ProjectileRef = SpawnActor(ProjectileType, FireOrigin.GetWorldLocation());
                NextFire = Gameplay::TimeSeconds + FireRate;
            }
        }
    }

    UFUNCTION()
    void PlayerInputSetup()
    {
        InputComp.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"MoveSides"));
        InputComp.BindAction(n"RestartLevel", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature (this, n"CallRestartLevel"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"FireWeaponOn"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"FireWeaponOff"));
    }

    UFUNCTION()
    void HandleYMovement()
    {
        float CurrentYLoc = GetActorLocation().Y;
        float NextYLoc = 0;

        float CamYCurrentLoc = SpringArm.GetRelativeLocation().Y;
        float CamYNewLoc = 0;
        float NextCamYLocDivider = 0;
        if (CurrentYPosition == 1)
        {
            NextYLoc = Ypos1;
            NextCamYLocDivider = Ypos4 / 6;
            CamYNewLoc = FMath::Lerp(CamYCurrentLoc, NextCamYLocDivider, 0.08f); 
            SpringArm.SetRelativeLocation(FVector(0,CamYNewLoc,0));
        }
        else if (CurrentYPosition == 2)
        {
            NextYLoc = Ypos2;
            NextCamYLocDivider = Ypos3 / 6;
            CamYNewLoc = FMath::Lerp(CamYCurrentLoc, NextCamYLocDivider, 0.08f); 
            SpringArm.SetRelativeLocation(FVector(0,CamYNewLoc,0));
        }
        else if (CurrentYPosition == 3)
        {
            NextYLoc = Ypos3;
            NextCamYLocDivider = Ypos2 / 6;
            CamYNewLoc = FMath::Lerp(CamYCurrentLoc, NextCamYLocDivider, 0.08f); 
            SpringArm.SetRelativeLocation(FVector(0,CamYNewLoc,0));
        }
        else if (CurrentYPosition == 4)
        {
            NextYLoc = Ypos4;
            NextCamYLocDivider = Ypos1 / 6;
            CamYNewLoc = FMath::Lerp(CamYCurrentLoc, NextCamYLocDivider, 0.08f); 
            SpringArm.SetRelativeLocation(FVector(0,CamYNewLoc,0));
        }

        float MovementValue = FMath::Lerp(CurrentYLoc, NextYLoc, 0.05f);

        SetActorLocation(FVector(GetActorLocation().X, MovementValue, GetActorLocation().Z));

        //for some reason this did not work...

        // Switch(CurrentYPosition)
        // {
        //     case 1:
        //     NextYLoc = Ypos1;
        //     break;
        //     case 2:
        //     NextYLoc = Ypos2;
        //     break;
        //     case 3:
        //     NextYLoc = Ypos3; 
        //     break;
        //     case 4;
        //     NextYLoc = Ypos4;
        //     break;
        // }

    }

    UFUNCTION()
    void MoveSides(float AxisValue)
    {
        if(IsAlive && AxisValue != 0 && NewMoveTime <= Gameplay::TimeSeconds) 
        {
            if (AxisValue < 0 && CurrentYPosition > 1)
            {
                NewMoveTime = Gameplay::TimeSeconds + MoveRate;
                CurrentYPosition--;
                Print("Moved to " + CurrentYPosition, 5);
            }
            else if (AxisValue > 0 && CurrentYPosition < 4)
            {
                NewMoveTime = Gameplay::TimeSeconds + MoveRate;
                CurrentYPosition++;
                Print("Moved to " + CurrentYPosition, 5);
            }


            /*
            if (AxisValue < 0 && GetActorLocation().Y <= -920)
            {
                CannotMove = true;
            }
            else if (AxisValue > 0 && GetActorLocation().Y >= 920)
            {
                CannotMove = true;
            }
            else 
            {
                 CannotMove = false;
            }

            if (!CannotMove)
            {
                AddMovementInput(ControlRotation.RightVector, AxisValue * MovementSpeed, true);
            }
            */
        }
    }

    UFUNCTION()
    void CallRestartLevel(FKey Key)
    {
        if (!IsAlive)
        {
            Gameplay::OpenLevel(n"MainMap");
        }
    }

    UFUNCTION()
    void FireWeaponOn(FKey Key)
    {
        CanFire = true;
    }

    UFUNCTION()
    void FireWeaponOff(FKey Key)
    {
        CanFire = false;
    }

    UFUNCTION()
    void DamagePlayer(int DamageAmount)
    {
        Health -= DamageAmount;
        GameMode.HealthRef = Health;
    }

    // UFUNCTION()
    // void UpdateMovementSpeed()
    // {
    //     MovementSpeed = GameMode.PlayerSpeed;
    //     Print("Player Speed: " + MovementSpeed, 5);
    // }

} 