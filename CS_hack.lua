-- Банальное ВХ (ESP Boxes) для тестов и обучения
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- Сюда будем сохранять созданные рамки
local boxes = {}

-- Функция создания рамки для одного игрока
local function createEsp(player)
    if player == localPlayer then return end

    -- Создаем квадрат через стандартную библиотеку Drawing
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0) -- Красный цвет
    box.Thickness = 2
    box.Filled = false

    boxes[player] = box
end

-- Функция удаления рамки при выходе игрока
local function removeEsp(player)
    if boxes[player] then
        boxes[player]:Remove()
        boxes[player] = nil
    end
end

-- Отслеживаем вход и выход игроков
players.PlayerAdded:Connect(createEsp)
players.PlayerRemoving:Connect(removeEsp)

-- Создаем рамки для тех, кто уже на сервере
for _, player in pairs(players:GetPlayers()) do
    createEsp(player)
end

-- Главный цикл: обновляем координаты рамок каждый кадр
runService.RenderStepped:Connect(function()
    for player, box in pairs(boxes) do
        local character = player.Character
        
        -- Проверяем, жив ли персонаж и есть ли у него HumanoidRootPart
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character.HumanoidRootPart
            
            if humanoid.Health > 0 then
                -- Переводим 3D координаты персонажа в 2D координаты экрана
                local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
                
                if onScreen then
                    -- Если игрок на экране, показываем рамку и задаем ей размер
                    box.Size = Vector2.new(2500 / screenPos.Z, 3500 / screenPos.Z)
                    box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
                    box.Visible = true
                else
                    -- Если игрок за спиной, скрываем рамку
                    box.Visible = false
                end
            else
                box.Visible = false -- Скрываем, если мертв
            end
        else
            box.Visible = false -- Скрываем, если персонаж еще не загрузился
        end
    end
end)

print("Банальное ВХ успешно загружено!")
