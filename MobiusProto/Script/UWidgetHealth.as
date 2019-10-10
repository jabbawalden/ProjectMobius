import AMobiusGameMode;

class UWidgetHealth : UUserWidget
{
    AMobiusGameMode GameMode;

    // UPROPERTY()
    // UImage Health1;
    // UPROPERTY()
    // UImage Health2;
    // UPROPERTY()
    // UImage Health3;

    UFUNCTION(BlueprintOverride)
    void Construct()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());
    }

    UFUNCTION(BlueprintCallable)
    int SetHealthAmount()
    {
        if (GameMode == nullptr)
        {
            return 0;
        }

        int Output = GameMode.HealthRef;
        return Output;
    }

    UFUNCTION(BlueprintEvent)
    UTextBlock GetHealthText()
    {
        throw("You must override GetMainText from the widget blueprint to return the correct text widget.");
        return nullptr;
    }


    UFUNCTION()
    void UpdateHealthText(int Amount)
    {
        UTextBlock Score = GetHealthText();
        Score.Text = FText::FromString("200" + Amount);   
        // Score.Text = FText::FromString("");     
    }

    // UFUNCTION(BlueprintOverride)
    // void Tick(FGeometry MyGeo ,float DeltaSeconds)
    // {
    //     UpdateHealthText(GameMode.HealthRef);
    // }
}

UFUNCTION(Category = "Player HUD")
void AddHealthWidgetToHUD(APlayerController PlayerController, TSubclassOf<UWidgetHealth> WidgetClass)
{
    UUserWidget UserWidget = WidgetBlueprint::CreateWidget(WidgetClass, PlayerController);
    UserWidget.AddToViewport();
}