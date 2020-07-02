AuctionatorBagClassListingMixin = {}

local ROW_LENGTH = 5

function AuctionatorBagClassListingMixin:OnLoad()
  self.items = {}
  self.buttons = {}
  self.buttonPool = CreateAndInitFromMixin(Auctionator.Utilities.PoolMixin)
  self.buttonPool:SetCreator(function()
    return CreateFrame("Frame", self.buttonNamePrefix .. #self.items,
                self.ItemContainer, "AuctionatorBagItem")
  end)
  self.isAuctionatorBag = true

  self.title = GetItemClassInfo(self.classId)

  self:UpdateTitle()
  self:SetHeight(self.SectionTitle:GetHeight())

  self.SectionTitle:SetWidth(self:GetRowWidth())
  self.SectionTitle.NormalTexture:SetWidth(self:GetRowWidth() + 8)
  self.SectionTitle.Text:SetPoint("LEFT", 12, 0)
  self.SectionTitle.HighlightTexture:SetSize(self:GetRowWidth() + 9, self.SectionTitle:GetHeight())

  self.buttonNamePrefix = self.title .. "Item"
  self:CreateEmptyButtons()

  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED) then
    self.ItemContainer:Hide()
  end
end

function AuctionatorBagClassListingMixin:CreateEmptyButtons()
  self.emptyButtons = {}
  local frame

  for count = 1, ROW_LENGTH - 1 do
    frame = CreateFrame("Frame", self.buttonNamePrefix .. "Empty" .. count, self.ItemContainer, "AuctionatorBagItem")
    frame:Hide()

    table.insert(self.emptyButtons, frame)
  end
end

function AuctionatorBagClassListingMixin:Reset()
  self.items = {}

  for index, item in ipairs(self.buttons) do
    item:Hide()
    self.buttonPool:Return(item)
  end

  self.buttons = {}
end

function AuctionatorBagClassListingMixin:GetRowWidth()
  return ROW_LENGTH * 42
end

function AuctionatorBagClassListingMixin:UpdateTitle()
  self.SectionTitle:SetText(self.title .. " (" .. #self.items .. ")")
end

function AuctionatorBagClassListingMixin:AddItems(itemList)
  for _, item in ipairs(itemList) do
    self:AddItem(item)
  end

  self:UpdateTitle()

  self:DrawButtons()

  self:UpdateForCollapsing()

  self:UpdateForEmpty()
end

function AuctionatorBagClassListingMixin:AddItem(item)
  local button = self.buttonPool:Get()

  button:Show()

  button:SetItemInfo(item)

  table.insert(self.buttons, button)
  table.insert(self.items, item)
end

function AuctionatorBagClassListingMixin:DrawButtons()
  local rows = 1
  local lastButton

  for _, button in ipairs(self.emptyButtons) do
    button:ClearAllPoints()
    button:Hide()
  end

  for index, button in ipairs(self.buttons) do
    lastButton = button

    if index == 1 then
      button:SetPoint("TOPLEFT", self.ItemContainer, "TOPLEFT", 0, -2)
    elseif ((index - 1) % ROW_LENGTH) == 0 then
      rows = rows + 1
      button:SetPoint("TOPLEFT", self.buttons[index - ROW_LENGTH], "BOTTOMLEFT")
    else
      button:SetPoint("TOPLEFT", self.buttons[index - 1], "TOPRIGHT")
    end
  end

  if (#self.buttons % ROW_LENGTH) ~= 0 then
    local emptyCount = ROW_LENGTH - (#self.buttons % ROW_LENGTH)

    for count = 1, emptyCount do
      self.emptyButtons[count]:SetPoint("TOPLEFT", lastButton, "TOPRIGHT")
      self.emptyButtons[count]:Show()

      lastButton = self.emptyButtons[count]
    end
  end

  if #self.buttons > 0 then
    self.ItemContainer:SetSize( self.buttons[1]:GetWidth() * 3, rows * 42 + 2)
  else
    self.ItemContainer:SetSize(0, 0)
  end

  self:SetSize(42 * ROW_LENGTH, self.ItemContainer:GetHeight() + self.SectionTitle:GetHeight())
end

function AuctionatorBagClassListingMixin:UpdateForCollapsing()
  if not self:IsVisible() then
    return
  end

  if not self.ItemContainer:IsVisible() then
    self:SetHeight(self.SectionTitle:GetHeight())
  else
    self:SetHeight(self.ItemContainer:GetHeight() + self.SectionTitle:GetHeight())
  end
end

-- Hide the frame if there are no buttons in it.
-- Anchors are updated to ensure a blank space isn't left behind
function AuctionatorBagClassListingMixin:UpdateForEmpty()
  -- Get the TOPLEFT anchor and its relative frame
  local relativeTo, relativePoint
  for i = 1, self:GetNumPoints() do
    local point = {self:GetPoint(1)}
    if point[1] == "TOPLEFT" then
      relativeTo = point[2]
      relativePoint = point[3]
      break
    end
  end

  -- Shift the title up slightly
  if #self.buttons == 0 then
    self:SetPoint("TOPLEFT", relativeTo, relativePoint, 0, self.SectionTitle:GetHeight())
    self:SetPoint("RIGHT", self:GetParent(), "RIGHT")
    self:Hide()
  else
    self:SetPoint("TOPLEFT", relativeTo, relativePoint, 0, 0)
    self:SetPoint("RIGHT", self:GetParent(), "RIGHT")
    self:Show()
  end
end

function AuctionatorBagClassListingMixin:OnClick()
  if self.ItemContainer:IsVisible() then
    self.ItemContainer:Hide()
  else
    self.ItemContainer:Show()
  end

  self:UpdateForCollapsing()
end
