import GameFiles.MMobiusGameMode;
import WorldFiles.MMainPlayer;
import WorldFiles.MObstacle;

class ALevelGeneratorV2 : AActor 
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneComp;

    UPROPERTY(DefaultComponent, Attach = SceneComp)
    UBoxComponent BoxCollision;

    UPROPERTY()
    AMobiusGameMode GameMode;

    // UPROPERTY(DefaultComponent, Attach = BoxCollision)
    // UStaticMeshComponent MeshComp;
    // default MeshComp.SetWorldScale3D(FVector(800, 25, 1));
    // // default MeshComp.StaticMesh = Asset("/Engine/BasicShapes/Cube.Cube");
    // default BoxCollision.SetBoxExtent(MeshComp.GetBoundingBoxExtents()); 

    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UStaticMeshComponent SpawnLoc;
    default SpawnLoc.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY()
    TArray<float> LocationPointX;
    UPROPERTY()
    TArray<float> LocationPointY;
    UPROPERTY()
    TArray<AActor> ObstacleStateArray;


    UPROPERTY(DefaultComponent, Attach = BoxCollision)
    UBoxComponent SpawnTriggerComp;
    default SpawnTriggerComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
    default SpawnTriggerComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

    UPROPERTY()
    TSubclassOf<AActor> LevelGeneratorType;
    AActor LevelGenerator;

    UPROPERTY()
    TSubclassOf<AActor> PointRepresentType;
    AActor PointRepresent;

    UPROPERTY()
    TSubclassOf<AActor> ObstacleType;
    AActor Obstacle;

    UPROPERTY()
    TSubclassOf<AActor> HealingItemType;
    AActor HealingItem;

    UPROPERTY()
    float MovementSpeed = 3000; //AMobiusGameMode.GlobalMovementSpeed;

    // float PointReferenceX;
    // float PointReferenceY;

    UPROPERTY()
    int NumberOfSpawn;

    // float XGridPosMultiplier = 600.0f;
    // float YGridPosMultiplier = 850.0f;
    // int XRows = 10.0f;
    // int YRowDirectionCount = 2.0f; 
    // float XPositionMultiplier = 100;
    // float YPositionMultiplier = 80;

    int XMaxCount;
    int XMinCount;
    UPROPERTY()
    int XTargetCount;
    int XCurrentSpawnCount;

    UPROPERTY()
    TArray<float> ChosenYIndex;
    UPROPERTY()
    TArray<float> ChosenXIndex;

    bool CanSpawnHealing;

    UFUNCTION(BlueprintOverride)
    void BeginPlay() 
    {
        XMaxCount = 15;
        XMinCount = 10;

        SpawnTriggerComp.OnComponentBeginOverlap.AddUFunction(this, n"TriggerOnBeginOverlap");

        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            MovementSpeed = GameMode.GlobalMovementSpeed;
            GameMode.EventSpeedIncrease.AddUFunction(this, n"MatchGlobalSpeed");
            GameMode.EventHaltSpeed.AddUFunction(this, n"MatchGlobalSpeed");
            SetTriggerScale();
            if (GameMode.HealthRef < GameMode.MaxHealthRef)
            {
                Print("CAN GENERATE HEALING ITEMS", 5);
                CanSpawnHealing = true;
            }
        }

        ConstructObstaclePositions();
        GenerateObstacles();
        SetObstacleType();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveLevel(DeltaSeconds);
    }

    UFUNCTION()
    void MatchGlobalSpeed()
    {
        MovementSpeed = GameMode.GlobalMovementSpeed;
    }

    UFUNCTION()
    void MoveLevel(float DeltaSeconds)
    {   
        FVector CurrentLoc = GetActorLocation();
        FVector NextLoc = CurrentLoc += FVector(-MovementSpeed * DeltaSeconds, 0, 0);
        SetActorLocation(NextLoc);
    }

    UFUNCTION()
    void TriggerOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
        bool bFromSweep, FHitResult& Hit) 
    {
        // Print("Overlapping with: " + OtherActor.Name, 5);

        AMainPlayer PlayerRef = Cast<AMainPlayer>(OtherActor);

        if (PlayerRef != nullptr)
        {
            SpawnNextLevel();
            if (GameMode != nullptr)
            {
                GameMode.CallIncreaseSpeedDelegate();
            }
            else 
            {
                Warning("Game Mode Null");
            }
        }
    }

    UFUNCTION()
    void SetTriggerScale()
    {
        float YMaxCount = GameMode.YMaxIndexCount + 1;
        float YScale = YMaxCount * 6.0f;
        SpawnTriggerComp.SetWorldScale3D(FVector(1, YScale, 1));
    }

    UFUNCTION()
    void SpawnNextLevel() 
    { 
        FVector SpawnLocationOffset =  FVector(GameMode.XRows * GameMode.XGridPosMultiplier,0,0) + this.GetActorLocation();  
        LevelGenerator = SpawnActor(LevelGeneratorType, SpawnLocationOffset); 
    }

    UFUNCTION() 
    void ConstructObstaclePositions()
    {
        float YOffset = GameMode.YRowDirectionCount * GameMode.YGridPosMultiplier;
        float XPos = GetActorLocation().X; 
        float YPos = GetActorLocation().Y - YOffset;

        for (int i = 0; i < GameMode.XRows; i++)
        {
            LocationPointX.Add(XPos);
            XPos += GameMode.XGridPosMultiplier; 
        }

        for (int i = -GameMode.YRowDirectionCount - 1; i < GameMode.YRowDirectionCount; i++)
        {
            LocationPointY.Add(YPos);
            YPos += GameMode.YGridPosMultiplier;
        }

    }

    UFUNCTION()
    void SelectSpawnLocations()
    {
        XTargetCount = FMath::RandRange(XMinCount, XMaxCount);
        int RowIntervals = GameMode.XRows / XTargetCount;
        int CurrentIndex = -1;

        for (int i = 0; i < XTargetCount; i++)
        {
            CurrentIndex += RowIntervals; 
            ChosenXIndex.Add(CurrentIndex);
        }

        int YPreviousLoc = 0;
        int YCurrentLoc = 0;

        for (int y = 0; y < ChosenXIndex.Num(); y++)
        {
            YCurrentLoc = FMath::RandRange(0, GameMode.YMaxIndexCount);
            
            while(YCurrentLoc == YPreviousLoc)
            {
                YCurrentLoc = FMath::RandRange(0, GameMode.YMaxIndexCount);
            }

            YPreviousLoc = YCurrentLoc;
            ChosenYIndex.Add(YCurrentLoc);
        }
    }

    UFUNCTION()
    void GenerateObstacles() 
    {
        SelectSpawnLocations();

        for(int x = 0; x < LocationPointX.Num(); x++)
        {
            float XLocation = LocationPointX[x];
            
            for (int y = 0; y < LocationPointY.Num(); y++) 
            {
                PointRepresent = SpawnActor(PointRepresentType, FVector(FVector(XLocation, LocationPointY[y], 150)));
            }
            NumberOfSpawn++;
        }

        for (int i = 0; i < ChosenXIndex.Num(); i++)
        {
            
            FVector CurrentSpawnLoc = FVector(LocationPointX[ChosenXIndex[i]], LocationPointY[ChosenYIndex[i]], 150);
            Obstacle = SpawnActor(ObstacleType, CurrentSpawnLoc);
            ObstacleStateArray.Add(Obstacle); 
        }
    }

    UFUNCTION()
    void SetObstacleType()
    {
        int MaxBreakables = FMath::RandRange(2,4);
        int Index = FMath::RandRange(0,2);
        int HealthTypeChance = FMath::RandRange(0,3);
        int HealthIndex = FMath::RandRange(0, ObstacleStateArray.Num() - 1);

        for (int i = 0; i < ObstacleStateArray.Num(); i++)
        {
            if (i == Index) 
            {
                if (i == HealthIndex)
                {
                    //make into health index
                    AActor ObstacleRef = ObstacleStateArray[i];
                    AObstacle ObstacleClass = Cast<AObstacle>(ObstacleRef);

                    if (ObstacleClass != nullptr && CanSpawnHealing)
                    {
                        ObstacleClass.ObstacleTypeDeclared(EObstacleType::Healing);
                    }
                }
                else 
                {
                    Index += MaxBreakables;
                    AActor ObstacleRef = ObstacleStateArray[i];
                    AObstacle ObstacleClass = Cast<AObstacle>(ObstacleRef);
                    if (ObstacleClass != nullptr)
                    {
                        ObstacleClass.ObstacleTypeDeclared(EObstacleType::Breakable);
                    }
                }

            }
        }   
    }
}