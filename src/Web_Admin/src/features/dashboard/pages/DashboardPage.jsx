import React, { useState, useEffect, useCallback } from 'react';
import { DatePicker, message, Spin, Row, Col } from 'antd';
import dayjs from 'dayjs'; 

import { dashboardApi } from '../api/dashboardApi';
import StatsCards from '../components/StatsCards'; 
import RevenueChart from '../components/RevenueChart';
import TopStores from '../components/TopStores';
import StatusPieChart from '../components/StatusPieChart';
import PendingActions from '../components/PendingActions';
import PageHeader from '../../../components/PageHeader';
import FilterBar from '../../../components/FilterBar';

const { RangePicker } = DatePicker;

const DashboardPage = () => {
    const [loading, setLoading] = useState(false);
    const [dashboardData, setDashboardData] = useState(null);
    const [dateRange, setDateRange] = useState([dayjs().subtract(30, 'day'), dayjs()]);

    const fetchDashboardData = useCallback(async (dates) => {
        setLoading(true);
        try {
            const fromDate = (dates && dates[0]) ? dates[0].startOf('day').format('YYYY-MM-DDTHH:mm:ss') : undefined;
            const toDate = (dates && dates[1]) ? dates[1].endOf('day').format('YYYY-MM-DDTHH:mm:ss') : undefined;

            const res = await dashboardApi.getStatistics(fromDate, toDate);
            if (res) { 
                setDashboardData(res.data || res); 
            }
        } catch (error) {
            message.error('Không thể tải dữ liệu tổng quan hệ thống!');
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchDashboardData(dateRange);
    }, [dateRange, fetchDashboardData]);

    if (loading && !dashboardData) {
        return (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', background: '#f8fafc' }}>
                <Spin size="large" description="Đang tải dữ liệu tổng quan..." />
            </div>
        );
    }

    return (
        <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
            <PageHeader 
                title="Bảng điều khiển Admin (Dashboard)" 
                extra={
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <span style={{ color: '#64748b', fontWeight: 500 }}>Bộ lọc thời gian:</span>
                        <RangePicker 
                            size="large" 
                            value={dateRange}
                            onChange={(dates) => setDateRange(dates || null)} 
                            style={{ borderRadius: '8px', width: '280px' }}
                            allowClear={true} 
                        />
                    </div>
                }
            />

            <StatsCards data={dashboardData} loading={loading} />

            <div style={{ marginBottom: '24px' }}>
                <PendingActions data={dashboardData?.pendingActions} />
            </div>

            <div style={{ marginBottom: '24px' }}>
                <RevenueChart data={dashboardData?.revenueChart} />
            </div>

            <Row gutter={[24, 24]}>
                <Col xs={24} lg={16}>
                    <TopStores data={dashboardData?.topStores} />
                </Col>
                <Col xs={24} lg={8}>
                    <StatusPieChart data={dashboardData?.bookingStatusStats} />
                </Col>
            </Row>
        </div>
    );
};

export default DashboardPage;