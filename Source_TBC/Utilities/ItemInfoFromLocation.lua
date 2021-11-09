-- Returns just enough information that the BagItem mixin can display the item
-- and the SaleItemMixin can post it.
function Auctionator.Utilities.ItemInfoFromLocation(location)
  local icon, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(location:GetBagAndSlot())
  local currentDurability, maxDurability = GetContainerItemDurability(location:GetBagAndSlot())

  local _, _, _, _, _, classID, _ = GetItemInfoInstant(itemLink)

  -- The first time the AH is loaded sometimes when a full scan is running the
  -- quality info may not be available. This just gives a sensible fail value.
  if quality == -1 then
    Auctionator.Debug.Message("Missing quality", itemLink)
    quality = 1
  end

  return {
    itemLink = itemLink,
    count = itemCount,
    iconTexture = icon,
    location = location,
    quality = quality,
    classId = classID,
    auctionable = not C_Item.IsBound(location) and currentDurability == maxDurability,
  }
end
