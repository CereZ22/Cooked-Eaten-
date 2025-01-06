RegisterNetEvent('Cooked-Eaten:pay', function(amount, item, method)
    local xPlayer = ESX.GetPlayerFromId(source)

    if method == 'cash' then
        -- Pagamento con contanti
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            TriggerClientEvent('Cooked-Eaten:paymentSuccess', source, item) -- Notifica il successo
        else
            TriggerClientEvent('Cooked-Eaten:paymentFailed', source, 'Non hai abbastanza contanti!')
        end
    elseif method == 'bank' then
        -- Pagamento con banca
        if xPlayer.getAccount('bank').money >= amount then
            xPlayer.removeAccountMoney('bank', amount)
            TriggerClientEvent('Cooked-Eaten:paymentSuccess', source, item) -- Notifica il successo
        else
            TriggerClientEvent('Cooked-Eaten:paymentFailed', source, 'Non hai abbastanza soldi in banca!')
        end
    else
        -- Metodo di pagamento non valido
        TriggerClientEvent('Cooked-Eaten:paymentFailed', source, 'Metodo di pagamento non valido!')
    end
end)
