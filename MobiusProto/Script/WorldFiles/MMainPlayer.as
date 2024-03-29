import GameFiles.MMobiusGameMode;
import GameFiles.MWidgetScore;
import GameFiles.MWidgetHealth;
import WorldFiles.MCustomCamera;
import GameFiles.MStatics;

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
    UPROPERTY()
    ACustomCamera PlayerCamera;

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

    bool IsAlive = true;
    bool CannotMove = false;

    int CurrentYPosition = 0;

    float NewMoveTime = 0;
    float MoveRate = 0.235;

    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {

    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());
        Health = MaxHealth;

        TArray<ACustomCamera> PlayerCam;
        ACustomCamera::GetAll(PlayerCam); 
        PlayerCamera = PlayerCam[0]; 
        PlayerCamera.SetGameModeReference();

        if (GameMode != nullptr)
        {
            GameMode.EventSetPlayerReference.Broadcast(this);  
            Print("Broadcast Event", 5);
        }

        PlayerInputSetup();
        APlayerController PlayerController = Gameplay::GetPlayerController(0);

        AddScoreWidgetToHUD(PlayerController, WidgetClassScore);
        AddHealthWidgetToHUD(PlayerController, WidgetClassHealth);

        PlayerController.SetViewTargetWithBlend(PlayerCamera, 0.0001);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds) 
    {
        if (IsAlive)
        {
            HandleFiring();
            HandleYMovement(DeltaSeconds);
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
        InputComp.BindAxis(n"KeysSideMovement", FInputAxisHandlerDynamicSignature(this, n"MoveSides"));
        InputComp.BindAction(n"RestartLevel", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature (this, n"CallRestartLevel"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"FireWeaponOn"));
        InputComp.BindAction(n"FireGun", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"FireWeaponOff"));
        
    }

    UFUNCTION()
    void HandleYMovement(float DeltaSeconds)
    {
        float CurrentYLoc = GetActorLocation().Y;
        float MovementValue = FMath::FInterpTo(CurrentYLoc, CurrentYPosition * GameMode.YGridPosMultiplier, DeltaSeconds, 20.0f);
        SetActorLocation(FVector(GetActorLocation().X, MovementValue, GetActorLocation().Z));
    }

    UFUNCTION()
    void MoveSides(float AxisValue)
    {
        if(IsAlive && AxisValue != 0 && NewMoveTime <= Gameplay::TimeSeconds) 
        {
            if (AxisValue < 0 && CurrentYPosition > -GameMode.YRowDirectionCount)
            {
                NewMoveTime = Gameplay::TimeSeconds + MoveRate;
                CurrentYPosition--;
            }
            else if (AxisValue > 0 && CurrentYPosition < GameMode.YRowDirectionCount)
            {
                NewMoveTime = Gameplay::TimeSeconds + MoveRate;
                CurrentYPosition++;
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

    UFUNCTION()
    void HealPlayer(int Amount)
    {
        Health += Amount;
        GameMode.HealthRef = Health;
    }

    // UFUNCTION()
    // void UpdateMovementSpeed()
    // {
    //     MovementSpeed = GameMode.PlayerSpeed;
    //     Print("Player Speed: " + MovementSpeed, 5);
    // }

} 