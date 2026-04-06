// 1. Trạng thái cửa hàng (Store)
export const StoreStatus = {
    Incomplete: -1,
    Pending: 0,
    Approved: 1,
    Locked: 2,
};

// 2. Trạng thái lịch hẹn (Booking)
export const BookingStatus = {
    Pending: 0,
    Confirmed: 1,
    Completed: 2,
    Cancelled: 3,
};

// 3. Phân quyền người dùng (Role)
export const UserRole = {
    Customer: 0,
    StoreOwner: 1,
    Admin: 2,
};

export const PAGINATION = {
    DEFAULT_PAGE_INDEX: 1,
    DEFAULT_PAGE_SIZE: 10,
};

export const UserStatus = {
    Active: 0,
    Locked: 1,
};