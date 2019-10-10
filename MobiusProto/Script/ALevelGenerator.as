import AMobiusGameMode;

class ALevelGenerator : AActor 
{
    AMobiusGameMode GameMode;

    UPROPERTY(DefaultComponent, RootComponent)
    UBoxComponent BoxCollision;
    default BoxCollision.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    default BoxCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);

    // UPROPERTY(DefaultComponent, Attach = BoxCollision)
    // UStaticMeshComponent MeshComp;
    // default MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UStaticMeshComponent MeshCompMain;
    default MeshCompMain.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UStaticMeshComponent MeshCompV2;
    default MeshCompV2.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UBoxComponent SpawnTriggerComp;
    default SpawnTriggerComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
    default SpawnTriggerComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

    UPROPERTY()
    TSubclassOf<AActor> LevelGeneratorType;
    AActor LevelGenerator;

    UPROPERTY()
    float MovementSpeed;

    UFUNCTION(BlueprintOverride)
    void ConstructionScript() 
    {
        // MeshComp.SetWorldScale3D(FVector(30, 8, 1));
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            Print("" + GameMode.HealthRef, 5); 
        }

        SpawnTriggerComp.OnComponentBeginOverlap.AddUFunction(this, n"TriggerOnBeginOverlap");
        Print("" + MeshCompMain.GetBoundingBoxExtents(), 5);
        MeshCompV2.SetRelativeLocation(FVector(MeshCompMain.GetBoundingBoxExtents().X * 0.165f, 0, 0));
        // OnComponentBeginOverlap.AddUFunction(this, n"TriggerBoxComponent");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveLevel(DeltaSeconds);
    }

    UFUNCTION()
    void MoveLevel(float DeltaSeconds)
    {   
        FVector CurrentLoc = GetActorLocation();
        FVector NextLoc = CurrentLoc += FVector(-MovementSpeed * DeltaSeconds, 0, 0);
        // Print("Level Loc is " + NextLoc, 5);
        SetActorLocation(NextLoc);
    }

    UFUNCTION()
    void TriggerOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
        bool bFromSweep, FHitResult& Hit) 
    {
        // Print("Overlapping with: " + OtherActor.Name, 5);
        SpawnNextLevel();
        Print("Overlapping", 5);
    }

    UFUNCTION()
    void SpawnNextLevel() 
    {
        // GetWorld().SpawnActor(ALevelGenerator&, MeshCompV2.GetWorldLocation(), FRotator(0), n"BP_LevelGenerator");
        //ALevelGenerator NewLevel = GetWorld().SpawnActor<ALevelGenerator>(LevelGenerator, MeshCompV2.GetWorldLocation()); 
        // SpawnActor(LevelGenerator, MeshCompV2.GetWorldLocation(), FRotator(0));
        LevelGenerator = SpawnActor(LevelGeneratorType, MeshCompV2.GetWorldLocation()); 
        Print("Level Spawn Called", 5);
    }

}