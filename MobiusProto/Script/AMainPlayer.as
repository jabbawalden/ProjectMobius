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