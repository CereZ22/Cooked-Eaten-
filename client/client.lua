ESX = exports["es_extended"]:getSharedObject()
local ox = exports.ox_inventory

-- Funzione per pagare e consumare
local function payAndConsume(item, paymentMethod)
    TriggerServerEvent('Cooked-Eaten:pay', 50, item, paymentMethod) -- Notifica il server per il pagamento
end

-- Funzione per aprire il menu di pagamento
local function openPaymentMenu(item)
    lib.registerContext({
        id = 'payment_menu',
        title = 'Scegli il metodo di pagamento',
        options = {
            {
                title = 'Contanti',
                description = 'Paga con contanti',
                icon = 'fas fa-wallet',
                onSelect = function()
                    payAndConsume(item, 'cash') -- Paga con contanti e consuma
                end
            },
            {
                title = 'Banca',
                description = 'Paga con conto bancario',
                icon = 'fas fa-credit-card',
                onSelect = function()
                    payAndConsume(item, 'bank') -- Paga con banca e consuma
                end
            }
        }
    })
    lib.showContext('payment_menu')
end

-- Funzione per aprire il menu principale
local function openMenu()
    lib.registerContext({
        id = 'cibo_menu',
        title = 'Negozio',
        options = {
            {
                title = 'Bevi ($50)',
                description = 'Soddisfa la tua sete',
                icon = 'fas fa-tint',
                onSelect = function()
                    openPaymentMenu('drink') -- Apre il menu di pagamento per "Bevi"
                end
            },
            {
                title = 'Mangia ($50)',
                description = 'Soddisfa la tua fame',
                icon = 'fas fa-hamburger',
                onSelect = function()
                    openPaymentMenu('eat') -- Apre il menu di pagamento per "Mangia"
                end
            },
        }
    })
    lib.showContext('cibo_menu')
end

RegisterNetEvent('Cooked-Eaten:openMenu', openMenu)

-- Gestione della risposta dal server
RegisterNetEvent('Cooked-Eaten:paymentSuccess', function(item)
    -- Aggiunge fame o sete dopo il pagamento
    local hunger = lib.progressCircle({
        duration = 1000,
        label = 'Consumando...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        }
    })

    if hunger then
        if item == 'drink' then
            TriggerEvent('esx_status:add', 'thirst', 500000) -- Aggiunge il 50% all'acqua
            lib.notify({type = 'success', title = 'Hai bevuto', description = 'La tua sete è stata soddisfatta!'})
        elseif item == 'eat' then
            TriggerEvent('esx_status:add', 'hunger', 500000) -- Aggiunge il 50% al cibo
            lib.notify({type = 'success', title = 'Hai mangiato', description = 'La tua fame è stata soddisfatta!'})
        end
    end
end)

RegisterNetEvent('Cooked-Eaten:paymentFailed', function(reason)
    lib.notify({type = 'error', title = 'Pagamento fallito', description = reason})
end)

-- Creazione dei ped
for k, v in pairs(CereZCibo) do
    CreateThread(function()
        local pedmodel = v.pedmodel
        local coords = v.coords
        local pedheading = v.pedheading

        -- Caricamento del modello del ped
        RequestModel(pedmodel)
        while not HasModelLoaded(pedmodel) do
            Wait(100)
        end

        -- Creazione del ped
        local ped = CreatePed(4, pedmodel, coords.x, coords.y, coords.z - 1.0, pedheading, false, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Interazione con ox_target o esx textui
        if Cibo.ox_target then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'open_menu',
                    label = 'Negozio',
                    icon = 'fas fa-store',
                    event = 'Cooked-Eaten:openMenu'
                }
            })
        else
            local textuiShown = false

            CreateThread(function()
                while true do
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - coords)

                    if distance < 2.0 and not textuiShown then
                        textuiShown = true
                        ESX.TextUI("[E] Open Cooked Eaten", "info")
                    elseif distance >= 2.0 and textuiShown then
                        textuiShown = false
                        ESX.HideUI()
                    end

                    if IsControlJustReleased(0, 38) and distance < 2.0 then
                        TriggerEvent('Cooked-Eaten:openMenu')
                    end

                    Wait(0)
                end
            end)
        end
    end)
end
