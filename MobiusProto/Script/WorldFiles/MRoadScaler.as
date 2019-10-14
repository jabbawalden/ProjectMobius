import GameFiles.MMobiusGameMode;

class AMobiusRoadScaler : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent MeshComp;

    AMobiusGameMode GameMode;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            float ScaleYRowCount = GameMode.YMaxIndexCount + 1;
            float ScaleYAmount = ScaleYRowCount * 3.2f;
            float ScaleXAmount = GameMode.XRows * 30.0f;

            MeshComp.SetWorldScale3D(FVector(ScaleXAmount, ScaleYAmount, 1));
        }
    }

}