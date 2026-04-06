import React, { useState, useEffect } from 'react';
import { bookingApi } from '../api/bookingApi';
import BookingFilter from '../components/BookingFilter';
import BookingList from '../components/BookingList';
import BookingDetailModal from '../components/BookingDetailModal';
import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const BookingPage = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ totalCount: 0, totalPages: 1, pageIndex: 1, pageSize: 10 });

  const [filters, setFilters] = useState({ 
    searchTerm: '', 
    status: '', 
    paymentStatus: '', 
    fromDate: null, 
    toDate: null 
  });
  
  const [selectedBookingId, setSelectedBookingId] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchBookings = async (pageToFetch = pagination.pageIndex) => {
    try {
      setLoading(true);
      const queryParams = { 
        pageIndex: pageToFetch, 
        pageSize: pagination.pageSize,
        ...(filters.searchTerm && { searchTerm: filters.searchTerm }),
        ...(filters.status !== '' && { status: filters.status }),
        ...(filters.paymentStatus !== '' && { paymentStatus: filters.paymentStatus }),
        ...(filters.fromDate && { fromDate: filters.fromDate }),
        ...(filters.toDate && { toDate: filters.toDate })
      };

      const data = await bookingApi.getBookings(queryParams);
      
      setBookings(data.items || data.Items || []);
      setPagination(prev => ({
        ...prev,
        pageIndex: pageToFetch, 
        totalCount: data.totalCount ?? data.TotalCount ?? prev.totalCount,
        totalPages: data.totalPages ?? data.TotalPages ?? prev.totalPages,
      }));
    } catch (error) {
      console.error("Lỗi khi tải danh sách lịch hẹn:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookings(1); 
  }, [filters]);

  const handleFilterChange = (name, value) => {
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  return (
    <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
      <PageHeader title="Quản lý Lịch hẹn (Bookings)" />

      <SectionCard>
        <BookingFilter 
          filters={filters} 
          onChange={handleFilterChange} 
          onRefresh={() => fetchBookings(1)} 
        />

        <BookingList 
          bookings={bookings}
          loading={loading}
          pagination={pagination}
          onPageChange={fetchBookings} 
          onViewDetail={(id) => {
            setSelectedBookingId(id);
            setIsModalOpen(true);
          }} 
        />
      </SectionCard>

      <BookingDetailModal 
        isOpen={isModalOpen}
        bookingId={selectedBookingId} 
        onClose={() => {
          setIsModalOpen(false);
          setSelectedBookingId(null);
        }}
        onRefresh={() => fetchBookings(pagination.pageIndex)} 
      />
    </div>
  );
};

export default BookingPage;