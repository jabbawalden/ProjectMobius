import UWidgetScore;

class AMainPlayer : APawn
{
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
    TSubclassOf<UWidgetScore> WidgetClass;
    UPROPERTY()
    UWidgetScore MyScoreWidget;

    bool CanFire = false;

    float NextFire;
    float FireRate = 0.1f;

    UPROPERTY(DefaultComponent)
    UInputComponent InputComp;

    UPROPERTY()
    float MovementSpeed = 3000;

    UPROPERTY()
    float Health = 3;

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

    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {
        SpringArm.SetRelativeRotation(FRotator(-25, 0, 0));
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        PlayerInputSetup();
        APlayerController PlayerController = Gameplay::GetPlayerController(0);
        AddWidgetToHUD(PlayerController, WidgetClass);
        
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds) 
    {
        if (CanFire && IsAlive)
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
        Print("Input set", 10);
        InputComp.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"MoveSides"));
        InputComp.BindAction(n"RestartLevel", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature (this, n"CallRestartLevel"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"FireWeaponOn"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"FireWeaponOff"));
    }

    UFUNCTION()
    void MoveSides(float AxisValue)
    {
        if(IsAlive) 
        {
            AddMovementInput(ControlRotation.RightVector, AxisValue * MovementSpeed, true);
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

} 