local defaultKey = Enum.KeyCode.RightControl

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local SubContainer = LocalPlayer.PlayerGui.Bingo.StaticDisplayArea.Cards.PlayerArea.Cards.Container.SubContainer

local autoMarking = false
local autoBingo = false
local toggleKey = defaultKey
local changingKey = false
local minimized = false
local keyDisabledWhileMinimized = false

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoBingoGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local titleLabel = Instance.new("TextLabel", Frame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Bloxy Bingo"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextStrokeTransparency = 0.8

local minimizeButton = Instance.new("TextButton", Frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 20
minimizeButton.BorderSizePixel = 0

local minimizedButton = Instance.new("TextButton")
minimizedButton.Size = UDim2.new(0, 120, 0, 40)
minimizedButton.Position = UDim2.new(0.4, 0, 0.6, 0)
minimizedButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
minimizedButton.Text = "AX-SCRIPT"
minimizedButton.TextColor3 = Color3.new(1, 1, 1)
minimizedButton.Font = Enum.Font.GothamBold
minimizedButton.TextSize = 14
minimizedButton.BorderSizePixel = 0
minimizedButton.Visible = false
minimizedButton.Active = true
minimizedButton.Draggable = true
minimizedButton.Parent = ScreenGui

local creditLabel = Instance.new("TextLabel", Frame)
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 1, -20)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "by AlexScriptX"
creditLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextSize = 12
creditLabel.TextStrokeTransparency = 1

local function createButton(text, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = Frame
    return button
end

local autoMarkButton = createButton("Auto Marcar: OFF", UDim2.new(0, 25, 0, 40))
local autoBingoButton = createButton("Auto Bingo: OFF", UDim2.new(0, 25, 0, 80))
local keybindButton = createButton("Cambiar Keybind", UDim2.new(0, 25, 0, 120))

function firebutton(button)
    if button then
        local connections = {
            getconnections(button.MouseButton1Click),
            getconnections(button.MouseButton1Down),
            button.Activated and getconnections(button.Activated) or {}
        }
        for _, connList in ipairs(connections) do
            for _, signal in ipairs(connList) do
                coroutine.wrap(function()
                    signal:Fire()
                end)()
            end
        end
    end
end

function findCardsContainer()
    if SubContainer:FindFirstChild("Blocks") then
        return SubContainer.Blocks.Block
    end
    for _, scrollType in ipairs({"HorizontalScroll", "VerticalScroll"}) do
        local scroll = SubContainer:FindFirstChild(scrollType)
        if scroll and scroll:FindFirstChild("Cards") then
            return scroll.Cards
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoMarking then
            local Cards = findCardsContainer()
            if Cards then
                for _, card in ipairs(Cards:GetChildren()) do
                    if card:IsA("Frame") and card:FindFirstChild("Content") and card.Content:FindFirstChild("Numbers") then
                        for _, button in ipairs(card.Content.Numbers:GetChildren()) do
                            coroutine.wrap(firebutton)(button)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if autoBingo then
            local BingoButton = SubContainer.Buttons.ClaimButton
            firebutton(BingoButton)
        end
    end
end)

autoMarkButton.MouseButton1Click:Connect(function()
    autoMarking = not autoMarking
    autoMarkButton.Text = "Auto Marcar: " .. (autoMarking and "ON" or "OFF")
end)

autoBingoButton.MouseButton1Click:Connect(function()
    autoBingo = not autoBingo
    autoBingoButton.Text = "Auto Bingo: " .. (autoBingo and "ON" or "OFF")
end)

keybindButton.MouseButton1Click:Connect(function()
    keybindButton.Text = "Presiona nueva tecla..."
    changingKey = true
end)

minimizeButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    minimizedButton.Visible = true
    minimized = true
    keyDisabledWhileMinimized = true
end)

minimizedButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    minimizedButton.Visible = false
    minimized = false
    keyDisabledWhileMinimized = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if changingKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        keybindButton.Text = "Tecla: " .. tostring(toggleKey.Name)
        changingKey = false
    elseif input.KeyCode == toggleKey and not keyDisabledWhileMinimized then
        Frame.Visible = not Frame.Visible
        if not minimized then
            minimizedButton.Visible = false
        end
    end
end)
